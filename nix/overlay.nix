self: super:
{
  nix2bazel = rec {
    tools = {
      bazel-compdb = super.callPackage ../compilation_database { };
    };
    lib = super.callPackage ./lib.nix { };
    pkgs = super.callPackage ../pkgs { inherit lib; };
  };
}
