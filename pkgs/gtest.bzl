package(default_visibility = ["//visibility:public"])

cc_library(
    name = "gtest",
    hdrs = glob(["include/gtest/**/*.h"]),
    srcs = ["lib/libgtest.so"],
    linkopts = ["-rpath", "@out@/lib"],
    includes = ["include"],
)

cc_library(
    name = "gtest_main",
    srcs = ["lib/libgtest_main.so"],
    linkopts = ["-rpath", "@out@/lib"],
    deps = [":gtest"],
)

cc_library(
    name = "gmock",
    hdrs = glob(["include/gmock/**/*.h"]),
    srcs = ["lib/libgmock.so"],
    linkopts = ["-rpath", "@out@/lib"],
    strip_include_prefix = "include",
)

cc_library(
    name = "gmock_main",
    srcs = ["lib/libgmock_main.so"],
    linkopts = ["-rpath", "@out@/lib"],
    deps = [":gmock"],
)
