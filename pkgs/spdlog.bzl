cc_library(
    name = "spdlog",
    defines = [
        "SPDLOG_COMPILED_LIB",
        "SPDLOG_FMT_EXTERNAL",
    ],
    hdrs = glob(["include/**/*.h"]),
    srcs = ["lib/libspdlog.a"],
    linkopts = ["-lpthread"],
    deps = ["@fmt"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
