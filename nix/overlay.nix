let
  sources = import ./sources.nix;
  bazel4nixpkgs = import sources.bazel4nixpkgs { };
  bazel = bazel4nixpkgs.bazel_4;
in
self: super:
{
  inherit bazel;
  nix2bazel = rec {
    tools = {
      bazel-compdb = super.callPackage ../compilation_database { };
    };
    lib = super.callPackage ./lib.nix { };
    pkgs = super.callPackage ../pkgs { inherit lib; };
  };
}
