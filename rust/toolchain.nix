{ symlinkJoin

, pesto

, cargo
, clippy
, rustc
, rustfmt
, rust-analyzer
}:
pesto.lib.wrapNixPackage {
  name = "rust_toolchain";
  package = symlinkJoin {
    name = "toolchain";
    paths = [
      cargo
      clippy
      rustc
      rustfmt
      rust-analyzer
    ];
  };
  buildFile = ./toolchain.bazel;
  extraWorkspace = pesto.lib.registerToolchains [
    "@rust_toolchain//:x86_64-unknown-linux-gnu"
  ];
}
