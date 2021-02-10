package(default_visibility = ["//visibility:public"])

cc_library(
    name = "grpc",
    hdrs = glob(["include/grpc/**/*.h"]),
    includes = ["include"],
    srcs = select({
      "@bazel_tools//src/conditions:darwin": ["lib/libgrpc.dylib"],
      "//conditions:default": ["lib/libgrpc.so"],
    }),
    linkopts = ["-rpath", "@out@/lib"],
)

cc_library(
    name = "grpcxx",
    hdrs = glob(["include/grpc++/**/*.h", "include/grpcpp/**/*.h"]),
    includes = ["include"],
    srcs = select({
      "@bazel_tools//src/conditions:darwin": ["lib/libgrpc++.dylib"],
      "//conditions:default": ["lib/libgrpc++.so"],
    }),
    linkopts = ["-rpath", "@out@/lib"],
    deps = [":grpc", "@protobuf"],
)

cc_library(
    name = "grpcxx_reflection",
    srcs = select({
      "@bazel_tools//src/conditions:darwin": ["lib/libgrpc++_reflection.dylib"],
      "//conditions:default": ["lib/libgrpc++_reflection.so"],
    }),
    linkopts = ["-rpath", "@out@/lib"],
    deps = [":grpcxx"],
)
