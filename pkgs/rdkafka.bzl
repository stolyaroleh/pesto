cc_library(
    name = "rdkafka",
    hdrs = glob(["include/**/*.h"]),
    srcs = ["lib/librdkafka.a"],
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)
