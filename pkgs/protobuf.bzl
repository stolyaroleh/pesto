cc_library(
    name = "protobuf",
    hdrs = glob(["include/**/*.h", "include/**/*.inc"]),
    srcs = ["lib/libprotobuf.so"],
    linkopts = ["-rpath", "@lib@/lib"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
