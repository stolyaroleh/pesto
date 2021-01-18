cc_library(
    name = "openssl",
    hdrs = glob(["include/**/*.h"]),
    srcs = ["lib/libssl.so", "lib/libcrypto.so"],
    linkopts = ["-rpath", "@out@/lib"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
