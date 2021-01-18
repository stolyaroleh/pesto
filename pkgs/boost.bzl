package(default_visibility = ["//visibility:public"])

cc_library(
    name = "headers",
    hdrs = glob(["include/**"]),
    includes = ["include"],
)

cc_library(
    name = "program_options",
    srcs = ["lib/libboost_program_options.a"],
    deps = [":headers"],
)

cc_library(
    name = "serialization",
    srcs = ["lib/libboost_serialization.a"],
    deps = [":headers"],
)
