cc_library(
    name = "protobuf",
    hdrs = glob(["include/**/*.h", "include/**/*.inc"]),
    srcs = select({
      "@bazel_tools//src/conditions:darwin": ["lib/libprotobuf.dylib"],
      "//conditions:default": ["lib/libprotobuf.so"],
    }),
    linkopts = ["-rpath", "@lib@/lib"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
