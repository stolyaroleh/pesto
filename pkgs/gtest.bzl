package(default_visibility = ["//visibility:public"])

cc_library(
    name = "gtest",
    hdrs = glob(["include/gtest/**/*.h"]),
    srcs = select({
      "@bazel_tools//src/conditions:darwin": ["lib/libgtest.dylib"],
      "//conditions:default": ["lib/libgtest.so"],
    }),
    linkopts = ["-rpath", "@out@/lib"],
    includes = ["include"],
)

cc_library(
    name = "gtest_main",
    srcs = select({
      "@bazel_tools//src/conditions:darwin": ["lib/libgtest_main.dylib"],
      "//conditions:default": ["lib/libgtest_main.so"],
    }),
    linkopts = ["-rpath", "@out@/lib"],
    deps = [":gtest"],
)

cc_library(
    name = "gmock",
    hdrs = glob(["include/gmock/**/*.h"]),
    srcs = select({
      "@bazel_tools//src/conditions:darwin": ["lib/libgmock.dylib"],
      "//conditions:default": ["lib/libgmock.so"],
    }),
    linkopts = ["-rpath", "@out@/lib"],
    strip_include_prefix = "include",
)

cc_library(
    name = "gmock_main",
    srcs = select({
      "@bazel_tools//src/conditions:darwin": ["lib/libgmock_main.dylib"],
      "//conditions:default": ["lib/libgmock_main.so"],
    }),
    linkopts = ["-rpath", "@out@/lib"],
    deps = [":gmock"],
)
