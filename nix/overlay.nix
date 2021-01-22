let
  sources = import ./sources.nix;
  bazel4nixpkgs = import sources.bazel4nixpkgs { };
  bazel = bazel4nixpkgs.bazel_4;
in
self: super:
let
  pkgs = (
    super.lib.makeExtensible (_: {
      inherit pesto;
      inherit (self) pkgs;
    })
  ).extend (import ../pkgs);
  pesto = {
    tools = {
      bazel-compdb = super.callPackage ../compilation_database { };
    };
    lib = super.callPackage ./lib.nix { };
    inherit pkgs;
  };
in
{
  inherit bazel pesto;
}
