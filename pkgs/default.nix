self: super:
let
  inherit (self) pkgs;
  inherit (self.pesto.lib) wrapBazelPackage wrapNixPackage;
  sources = import ../nix/sources.nix { };
in
{
  clang_tidy = pkgs.callPackage ../cpp/clang_tidy { };

  clang_format = pkgs.callPackage ../cpp/clang_format { };

  rust_toolchain = pkgs.callPackage ../rust/toolchain.nix { };

  abseil = wrapBazelPackage {
    name = "abseil";
    src = pkgs.abseil-cpp.src;
    buildFileName = "BUILD.bazel";
  };

  bazel_skylib = wrapBazelPackage {
    name = "bazel_skylib";
    src = sources.bazel-skylib;
  };

  rules_rust = wrapBazelPackage {
    name = "rules_rust";
    src = sources.rules_rust;
    deps = [
      self.bazel_skylib
    ];
    buildFileName = "BUILD.bazel";
  };

  backward = wrapNixPackage {
    name = "backward";
    package = pkgs.backward-cpp;
    buildFile = ./backward.bzl;
  };

  benchmark = wrapNixPackage {
    name = "benchmark";
    package = pkgs.benchmark;
    buildFile = ./benchmark.bzl;
  };

  boost = wrapNixPackage {
    name = "boost";
    package = pkgs.boost17x;
    buildFile = ./boost.bzl;
  };

  cppkafka = wrapNixPackage {
    name = "cppkafka";
    package = pkgs.cppkafka;
    deps = [ self.rdkafka ];
    buildFile = ./cppkafka.bzl;
  };

  ctre = wrapNixPackage {
    name = "ctre";
    package = pkgs.ctre;
    buildFile = ./ctre.bzl;
  };

  date = wrapNixPackage {
    name = "date";
    package = pkgs.date;
    buildFile = ./date.bzl;
  };

  eigen = wrapNixPackage {
    name = "eigen";
    package = pkgs.eigen;
    buildFile = ./eigen.bzl;
  };

  fmt = wrapNixPackage {
    name = "fmt";
    package = pkgs.fmt;
    buildFile = ./fmt.bzl;
  };

  grpc = wrapNixPackage {
    name = "grpc";
    package = pkgs.grpc;
    buildFile = ./grpc.bzl;
    deps = [ self.protobuf ];
  };

  gtest = wrapNixPackage {
    name = "gtest";
    package = pkgs.gtest;
    buildFile = ./gtest.bzl;
  };

  nlohmann_json = wrapNixPackage {
    name = "nlohmann_json";
    package = pkgs.nlohmann_json;
    buildFile = ./nlohmann_json.bzl;
  };

  openssl = wrapNixPackage {
    name = "openssl";
    package = pkgs.openssl;
    buildFile = ./openssl.bzl;
  };

  pqxx = wrapNixPackage {
    name = "pqxx";
    package = pkgs.libpqxx;
    buildFile = ./pqxx.bzl;
  };

  protobuf = wrapNixPackage {
    name = "protobuf";
    package = pkgs.protobuf;
    buildFile = ./protobuf.bzl;
  };

  range-v3 = wrapBazelPackage {
    name = "range-v3";
    src = pkgs.range-v3.src;
    buildFile = "BUILD.bazel";
  };

  rapidcheck = wrapNixPackage {
    name = "rapidcheck";
    package = pkgs.rapidcheck;
    buildFile = ./rapidcheck.bzl;
  };

  rdkafka = wrapNixPackage {
    name = "rdkafka";
    package = pkgs.rdkafka;
    buildFile = ./rdkafka.bzl;
  };

  spdlog = wrapNixPackage {
    name = "spdlog";
    package = pkgs.spdlog;
    deps = [ self.fmt ];
    buildFile = ./spdlog.bzl;
  };

  tl_expected = wrapNixPackage {
    name = "tl_expected";
    package = pkgs.tl-expected;
    buildFile = ./tl_expected.bzl;
  };

  type_safe = wrapNixPackage {
    name = "type_safe";
    package = pkgs.type_safe;
    buildFile = ./type_safe.bzl;
  };

  zlib = wrapNixPackage {
    name = "zlib";
    package = pkgs.zlib;
    buildFile = ./zlib.bzl;
  };
}
