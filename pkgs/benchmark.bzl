package(default_visibility = ["//visibility:public"])

cc_library(
    name = "benchmark",
    hdrs = glob(["include/benchmark/*.h"]),
    srcs = ["lib/libbenchmark.a"],
    includes = ["include"],
)

cc_library(
    name = "main",
    srcs = ["lib/libbenchmark_main.a"],
    deps = [":benchmark"],
)
