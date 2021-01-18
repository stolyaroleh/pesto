cc_library(
    name = "zlib",
    hdrs = glob(["include/*.h"]),
    srcs = ["lib/libz.a"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
