cc_library(
    name = "cppkafka",
    hdrs = glob(["include/**/*.h"]),
    srcs = ["lib/libcppkafka.so"],
    deps = ["@rdkafka"],
    linkopts = ["-rpath", "@out@/lib"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
