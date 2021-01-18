cc_library(
    name = "pqxx",
    hdrs = glob(["include/**"]),
    includes = ["include"],
    srcs = ["lib/libpqxx.so"],
    linkopts = ["-rpath", "@out@/lib"],
    visibility = ["//visibility:public"],
)
