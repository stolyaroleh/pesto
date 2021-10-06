let
  sources = import ./sources.nix;
in
self: super:
let
  pesto = rec {
    tools = {
      bazel-compdb = super.callPackage ../cpp/compilation_database { };
    };
    lib = self.callPackage ./lib.nix {
      ccEnv = self.callPackage ../cpp {
        inherit bazelPkgs;
        inherit (tools) bazel-compdb;
      };
      rustEnv = self.callPackage ../rust {
        inherit bazelPkgs;
      };
    };
    bazelPkgs = (
      super.lib.makeExtensible (_: {
        inherit pesto;
        inherit (self) pkgs;
      })
    ).extend (import ../pkgs);
  };

in
{
  inherit pesto;
  bazel = super.bazel_4;
}
