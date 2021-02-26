{ lib, pkgs, bazel, openjdk11_headless, stdenv }:
rec {
  # Combine a Nix package with a BUILD file describing its contents,
  # to use with https://docs.bazel.build/versions/master/be/workspace.html#local_repository.
  wrapNixPackage =
    { package
    , buildFile
    , deps ? [ ]
    , name ? package.pname or package.name
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
    };

  # Wrap an existing Bazel project.
  wrapBazelPackage =
    { name
    , src
    , buildFile ? "BUILD"
    , deps ? [ ]
    }:
    {
      inherit name deps buildFile;
      symlink = "ln -nsfv ${src} external/${name}";
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
    let
      localRepository =
        pkg: ''
          new_local_repository(
            name = "${pkg.name}",
            path = "./external/${pkg.name}",
            build_file = "./external/${pkg.name}/${pkg.buildFile or "BUILD"}",
          )
        '';
    in
    lib.concatMapStringsSep "\n" localRepository deps;

  # Symlink all external repositories and a WORKSPACE file that references them.
  symlinkDeps = deps:
    let
      allDeps = (lib.concatMap transitiveClosure deps) ++ deps;
      workspaceFile = pkgs.writeTextFile {
        name = "WORKSPACE";
        text = generateWorkspace allDeps;
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
    , cc ? true

    , ...
    }@args:
    let
      # Given a file, read words from it by splitting on whitespace
      readWords = f:
        let
          rawFlags = builtins.readFile f;
          matches = builtins.split "[[:space:]]+" rawFlags;
          flags = builtins.filter
            (
              x:
              !(builtins.isList x) &&
              x != ""
            )
            matches;
        in
        flags;
      # Given a file with compiler flags that lives in ${cc-wrapper}/nix-support,
      # parse flags and join them with ":" to pass it to Bazel as an
      # environment variable.
      readFlags = fs:
        lib.concatStringsSep ":" (builtins.concatMap readWords fs);
      # Given a file with propagated build inputs that lives in ${cc-wrapper}/nix-support,
      # parse libraries and join them with ":" to pass them to Bazel.
      readLibs = fs:
        let libs = builtins.concatMap readWords fs;
        in
        lib.concatStringsSep ":"
          (
            map
              # Ensure that toolchain libraries (libc++, libunwind, etc) are added to RPATH,
              # so that resulting executables know how to run themselves.
              (x: "-L${x}/lib:-rpath:${x}/lib")
              libs
          );
      # Return a list of files in a given directory.
      getFiles = dir:
        lib.remove null (
          lib.mapAttrsToList
            (name: type: if type == "regular" then "${dir}/${name}" else null)
            (builtins.readDir dir)
        );
      # Find files that end with given suffices in a given directory.
      findFiles = dir: suffices:
        builtins.filter
          (name: builtins.any (suffix: lib.hasSuffix suffix name) suffices)
          (getFiles dir);

      cc-wrapper = stdenv.cc;
      cc-unwrapped = cc-wrapper.cc;
      # Compose a set of environment variables to help Bazel detect C++ toolchain.
      ccEnv = lib.optionalAttrs cc {
        # The following environment variables control Bazel C++ toolchain detection.
        CC =
          if cc-wrapper.isClang
          then "${cc-wrapper}/bin/clang++"
          else "${cc-wrapper}/bin/g++";
        BAZEL_CXXOPTS = (
          readFlags (
            findFiles "${cc-wrapper}/nix-support" [ "cflags" "cxxflags" ]
          )
        ) + ":-Wno-unused-command-line-argument";
        BAZEL_LINKOPTS = (
          readFlags (
            findFiles "${cc-wrapper}/nix-support" [ "cflags" "cxxflags" "ldflags" ]
          )
        ) + ":" + (
          readLibs (
            findFiles "${cc-wrapper}/nix-support" [ "propagated-target-target-deps" ]
          )
        );
      };
      ccBuildInputs = lib.optionals cc ([
        cc-wrapper
      ]);
      ccFlags = lib.concatStringsSep " " [
        "--compilation_mode=${compilationMode}"
      ];

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
    in
    pkgs.stdenvNoCC.mkDerivation (
      {
        preBuild = ''
          export HOME=/tmp
          ${symlinkDeps deps}
        '';

        nativeBuildInputs =
          args.nativeBuildInputs or [ ]
          ++ ccBuildInputs
          ++ [
            bazel
            openjdk11_headless
          ];
        buildPhase = ''
          runHook preBuild

          bazel build ${ccFlags} ${lib.concatStringsSep " " (binaries ++ tests)}

          runHook postBuild
        '';
        doCheck = tests != [ ];
        checkPhase = ''
          runHook preCheck

          bazel test ${ccFlags} ${lib.concatStringsSep " " tests}

          runHook postCheck
        '';
        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin
          bazelbin=$(bazel info ${ccFlags} bazel-bin)
          ${lib.concatMapStringsSep "\n" installLabel binaries}

          runHook postInstall
        '';
        shellHook = symlinkDeps deps;
      } // (lib.optionalAttrs cc ccEnv) // (
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
