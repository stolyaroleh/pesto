self: super:
let
  inherit (self) pkgs;
  inherit (self.pesto.lib) wrapBazelPackage wrapNixPackage;
in
{
  clang_tidy = pkgs.callPackage ../clang_tidy { };

  clang_format = pkgs.callPackage ../clang_format { };

  abseil = wrapBazelPackage {
    name = "abseil";
    src = pkgs.abseil-cpp.src;
    buildFile = "BUILD.bazel";
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
    package = pkgs.fmtlib;
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
