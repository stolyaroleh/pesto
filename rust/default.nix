{ cargo, cargo-raze, bazelPkgs }:
{
  env = {
    RUST_BACKTRACE = "1";
  };
  nativeBuildInputs = [
    cargo
    cargo-raze
  ];
  deps = with bazelPkgs; [
    rust_toolchain
    rules_rust
  ];
}
