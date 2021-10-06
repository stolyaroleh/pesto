cc_library(
    name = "fmt",
    hdrs = glob(["include/**/*.h"]),
    srcs = ["lib/libfmt.so"],
    includes = ["include"],
    linkopts = ["-Wl,-rpath,@out@/lib"],
    visibility = ["//visibility:public"],
)
