cc_library(
    name = "pqxx",
    hdrs = glob(["include/**"]),
    includes = ["include"],
    srcs = select({
      "@bazel_tools//src/conditions:darwin": ["lib/libpqxx.dylib"],
      "//conditions:default": ["lib/libpqxx.so"],
    }),
    linkopts = ["-rpath", "@out@/lib"],
    visibility = ["//visibility:public"],
)
