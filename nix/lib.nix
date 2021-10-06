{ lib
, pkgs

, bazel
, openjdk11_headless

, ccEnv
, rustEnv
}:
rec {
  # A section in WORKSPACE that imports a package using new_local_repository
  newLocalRepository =
    name: buildFile:
    ''
      new_local_repository(
        name = "${name}",
        path = "./external/${name}",
        build_file = "./external/${name}/${buildFile}",
      )
    '';

  registerToolchains =
    labels:
    ''
      register_toolchains(${lib.concatStringsSep ", " (map (x: ''"${x}"'') labels)})
    '';

  # Combine a Nix package with a BUILD file describing its contents,
  # to use with https://docs.bazel.build/versions/master/be/workspace.html#local_repository.
  wrapNixPackage =
    { package
    , buildFile
    , deps ? [ ]
    , name ? package.pname or package.name
    , extraWorkspace ? null
    }:
    let
      outputPaths = builtins.map (output: package.${output}) package.outputs;
      # Make it possible to refer to package outputs with @output@ in the build file.
      # This is useful when wrapping shared libraries, since they require
      # adding `-rpath $out/lib` to compile flags;
      # otherwise executables built with Bazel won't be able to run themselves.
      build =
        let
          substitutions =
            lib.concatMapStringsSep
              "\n"
              (
                output:
                ''sed -e "s|@${output}@|${package.${output}}|g" -i $out/BUILD''
              )
              package.outputs;
        in
        pkgs.runCommand
          "${name}-BUILD"
          { buildInputs = [ pkgs.gnused ]; }
          ''
            mkdir -p $out
            cp ${buildFile} $out/BUILD
            ${substitutions}
          '';
      combinedOutputs = pkgs.symlinkJoin {
        inherit name;
        paths = outputPaths ++ [ build ];
      };
    in
    {
      inherit name deps;
      symlink = "ln -nsfv ${combinedOutputs} external/${name}";
      workspace = (
        newLocalRepository name "BUILD" +
        lib.optionalString (extraWorkspace != null) extraWorkspace
      );
    };

  # Wrap an existing Bazel project.
  wrapBazelPackage =
    { name
    , src
    , buildFileName ? "BUILD"
    , deps ? [ ]
    }:
    {
      inherit name deps;
      symlink = "ln -nsfv ${src} external/${name}";
      workspace = newLocalRepository name buildFileName;
    };

  # Collect the transitive closure of all external repositories for a given project.
  transitiveClosure =
    dep:
    if dep.deps == [ ]
    then [ ]
    else dep.deps ++ (
      lib.concatMap transitiveClosure dep.deps
    );

  # Given a list of wrapped packages, generate a WORKSPACE file
  # referencing them.
  generateWorkspace = deps:
    lib.concatMapStringsSep "\n" (pkg: pkg.workspace) deps;

  # Symlink all external repositories and a WORKSPACE file that references them.
  symlinkDeps = deps: extraWorkspace:
    let
      allDeps = (lib.concatMap transitiveClosure deps) ++ deps;
      workspaceFile = pkgs.writeTextFile {
        name = "WORKSPACE";
        text = generateWorkspace allDeps + extraWorkspace;
      };
    in
    ''
      rm -rf external WORKSPACE
      mkdir -p external
      ln -nsfv ${workspaceFile} WORKSPACE
      ${lib.concatMapStringsSep "\n" (dep: dep.symlink) allDeps}
    '';

  # Given a directory with a C++ project, filter out unimportant files.
  cppSources =
    root:
    {
      # Additional directories to exclude.
      # A list of regular expressions that will be matched on directory name
      # relative to root.
      excludeDirs ? [ ]
      # Print traversed directories during evaluation.
    , debug ? false
    }:
    let
      shouldTraverseDir =
        dir:
        let
          base = builtins.baseNameOf dir;
          defaultExcludeDirs = [
            # .idea
            # .vscode
            "(.*/)*\\..*"
            # build directories
            "bazel-.*"
            # created by python test scripts, if any
            "(.*/)*__pycache__"
            # We symlink dependencies here
            "external"
          ];
          shouldTraverse =
            (
              builtins.all
                (re: builtins.match "${builtins.toString root}/${re}" dir == null)
                (defaultExcludeDirs ++ excludeDirs)
            );
        in
        if debug && shouldTraverse
        then builtins.trace "cppSources: ${dir}" shouldTraverse
        else shouldTraverse;
      fileSuffices = [
        ".h"
        ".cc"
        ".hpp"
        ".cpp"
        ".bzl"
        ".bazelrc"
        "BUILD"
      ];
      shouldIncludeFile =
        file:
        builtins.any
          (suffix: lib.hasSuffix suffix file)
          fileSuffices;
    in
    lib.cleanSourceWith {
      filter = name: type: (
        (type == "directory" && shouldTraverseDir name)
        || (type == "regular" && shouldIncludeFile name)
      );
      src = root;
    };

  bazelProject = lib.makeOverridable (
    { deps
    , binaries
    , tests ? [ ]

    , compilationMode ? "opt"
    , cc ? false
    , rust ? false

    , extraWorkspace ? ""

    , ...
    }@args:
    let
      labelToPath =
        label:
        builtins.replaceStrings [ "//" ":" ] [ "" "/" ] label;
      installLabel =
        label:
        let
          path = labelToPath label;
          dir = builtins.dirOf path;
        in
        ''
          mkdir -p $out/bin/${dir}
          cp $bazelbin/${path} $out/bin/${dir}
        '';

      needCC = cc || rust;
      needRust = rust;

      exportEnvVars =
        let
          envVars = (
            (lib.optionalAttrs needCC ccEnv.env) //
            (lib.optionalAttrs needRust rustEnv.env)
          );
          export = name: value: "export ${name}=${value}";
          exports = lib.mapAttrsToList export envVars;
        in
        lib.concatStringsSep "\n" exports;

      bazelFlags = lib.concatStringsSep " " (
        lib.optionals needCC ccEnv.flags or [ ] ++
        lib.optionals needRust rustEnv.flags or [ ] ++
        [ "--compilation_mode=${compilationMode}" ]
      );


      setupProject = symlinkDeps
        (
          lib.optionals needCC ccEnv.deps or [ ] ++
          lib.optionals needRust rustEnv.deps or [ ] ++
          deps
        )
        extraWorkspace;
    in
    pkgs.stdenvNoCC.mkDerivation (
      {
        preBuild = ''
          export HOME=/tmp
          ${setupProject}
          ${exportEnvVars}
        '';

        nativeBuildInputs =
          args.nativeBuildInputs or [ ]
          ++ lib.optionals needCC ccEnv.nativeBuildInputs or [ ]
          ++ lib.optionals needRust rustEnv.nativeBuildInputs or [ ]
          ++ [
            bazel
            openjdk11_headless
          ];
        buildPhase = ''
          runHook preBuild

          bazel build ${bazelFlags} ${lib.concatStringsSep " " (binaries ++ tests)}

          runHook postBuild
        '';
        doCheck = tests != [ ];
        checkPhase = ''
          runHook preCheck

          bazel test ${bazelFlags} --test_output=errors ${lib.concatStringsSep " " tests}

          runHook postCheck
        '';
        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin
          bazelbin=$(bazel info ${bazelFlags} bazel-bin)
          ${lib.concatMapStringsSep "\n" installLabel binaries}

          runHook postInstall
        '';
        shellHook = ''
          ${setupProject}
          ${exportEnvVars}
        '';
      } // (
        builtins.removeAttrs
          args
          [
            "deps"
            "binaries"
            "tests"
            "cc"
            "compilationMode"
            "nativeBuildInputs"
          ]
      )
    )
  );
}
