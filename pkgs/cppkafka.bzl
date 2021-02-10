cc_library(
    name = "cppkafka",
    hdrs = glob(["include/**/*.h"]),
    srcs = select({
      "@bazel_tools//src/conditions:darwin": ["lib/libcppkafka.dylib"],
      "//conditions:default": ["lib/libcppkafka.so"],
    }),
    deps = ["@rdkafka"],
    linkopts = ["-rpath", "@out@/lib"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
