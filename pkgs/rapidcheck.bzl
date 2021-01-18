cc_library(
    name = "rapidcheck",
    hdrs = glob(["include/**/*.h", "include/**/*.hpp"]),
    srcs = ["lib/librapidcheck.a"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
