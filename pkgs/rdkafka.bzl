cc_library(
    name = "rdkafka",
    hdrs = glob(["include/**/*.h"]),
    srcs = ["lib/librdkafka.a"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
