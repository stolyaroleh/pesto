let
  sources = import ./sources.nix;
  bazel4nixpkgs = import sources.bazel4nixpkgs { };
in
self: super:
let
  pesto = {
    tools = {
      bazel-compdb = super.callPackage ../compilation_database { };
    };

    lib = self.callPackage ./lib.nix { };
    pkgs = (
      super.lib.makeExtensible (_: {
        inherit pesto;
        inherit (self) pkgs;
      })
    ).extend (import ../pkgs);
  };
in
{
  inherit pesto;
  inherit (bazel4nixpkgs) openjdk11_headless;
  bazel = bazel4nixpkgs.bazel_4;
}
