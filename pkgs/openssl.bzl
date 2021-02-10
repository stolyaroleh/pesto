cc_library(
    name = "openssl",
    hdrs = glob(["include/**/*.h"]),
    srcs = select({
      "@bazel_tools//src/conditions:darwin": ["lib/libssl.dylib", "lib/libcrypto.dylib"],
      "//conditions:default": ["lib/libssl.so", "lib/libcrypto.so"],
    }),
    linkopts = ["-rpath", "@out@/lib"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
