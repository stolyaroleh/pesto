cc_library(
    name = "fmt",
    hdrs = glob(["include/**/*.h"]),
    srcs = ["lib/libfmt.a"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
