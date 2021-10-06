{ lib
, stdenv

, bazelPkgs
, bazel-compdb
}:
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
  # Given a list of derivations, construct linker flags that
  # will include their libraries
  addLibs = lib.concatMapStringsSep
    ":"
    (lib: "-L${lib.out}/lib:-rpath:${lib.out}/lib");
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
in
{
  env = {
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
    ) + ":" + addLibs cc-wrapper.depsTargetTargetPropagated;
  };
  nativeBuildInputs = [
    cc-wrapper
    bazel-compdb
  ];
}
