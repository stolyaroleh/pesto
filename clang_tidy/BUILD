package(default_visibility = ["//visibility:public"])

sh_binary(
    name = "clang_tidy",
    srcs = ["clang_tidy.sh"],
)

sh_binary(
    name = "clang_tidy_check",
    srcs = ["clang_tidy_check.sh"],
)

filegroup(
    name = "clang_tidy_config",
    srcs = [".clang-tidy"],
)
