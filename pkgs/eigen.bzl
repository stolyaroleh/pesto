cc_library(
    name = "eigen",
    hdrs = glob(["include/eigen3/**/*"]),
    includes = ["include/eigen3"],
    visibility = ["//visibility:public"],
)
