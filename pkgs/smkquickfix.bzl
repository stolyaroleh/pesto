cc_library(
    name = "smkquickfix",
    hdrs = glob(["include/**/*.h"]),
    includes = ["include"],
    srcs = ["lib/libquickfix.so"],
    linkopts = ["-rpath", "@out@/lib"],
    visibility = ["//visibility:public"],
)
