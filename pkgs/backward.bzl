cc_library(
    name = "backward",
    hdrs = glob(["include/*.hpp"]),
    includes = ["include"],
    visibility = ["//visibility:public"],
)
