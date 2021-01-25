load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@rules_cc//cc:action_names.bzl", "CPP_COMPILE_ACTION_NAME")

def _run_tidy(ctx, flags, compilation_context, infile):
    clang_tidy = ctx.attr._clang_tidy
    clang_tidy_config = ctx.attr._clang_tidy_config
    args = ctx.actions.args()

    fixes = ctx.actions.declare_file(infile.basename + ".clang-tidy.yaml", sibling = infile)
    logs = ctx.actions.declare_file(infile.basename + ".clang-tidy.log", sibling = infile)

    args.add(fixes.path)
    args.add(logs.path)

    # add source to check
    args.add(infile.path)

    # start args passed to the compiler
    args.add("--")

    # add args specified by the toolchain, on the command line and rule copts
    args.add_all(flags)

    # add defines
    for define in compilation_context.defines.to_list():
        args.add("-D" + define)

    for define in compilation_context.local_defines.to_list():
        args.add("-D" + define)

    # add includes
    for i in compilation_context.framework_includes.to_list():
        args.add("-F" + i)

    for i in compilation_context.includes.to_list():
        args.add("-I" + i)

    args.add_all(compilation_context.quote_includes.to_list(), before_each = "-iquote")

    args.add_all(compilation_context.system_includes.to_list(), before_each = "-isystem")

    ctx.actions.run(
        inputs = depset(
            [infile],
            transitive = [
                clang_tidy_config[DefaultInfo].files,
                compilation_context.headers,
            ],
        ),
        outputs = [fixes, logs],
        executable = clang_tidy[DefaultInfo].files_to_run,
        arguments = [args],
        mnemonic = "ClangTidy",
        progress_message = "Run clang-tidy on {}".format(infile.short_path),
    )
    return (fixes, logs)

def _rule_sources(ctx):
    srcs = []
    if hasattr(ctx.rule.attr, "srcs"):
        for src in ctx.rule.attr.srcs:
            srcs += src.files.to_list()
    return srcs

def _toolchain_flags(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
    )
    compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        user_compile_flags = ctx.fragments.cpp.cxxopts + ctx.fragments.cpp.copts,
    )
    flags = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = CPP_COMPILE_ACTION_NAME,
        variables = compile_variables,
    )
    return flags

def _safe_flags(flags):
    return [
        flag
        for flag in flags
        if flag not in (
            # This flag might be used by GCC but not understood by clang
            "-fno-canonical-system-headers",
            # Bazel redefines these macros to make builds reproducible,
            # but clang-tidy ignores -Wno-builtin-macro-redefined and errors anyways
            '-D__DATE__="redacted"',
            '-D__TIMESTAMP__="redacted"',
            '-D__TIME__="redacted"',
        )
    ]

def _clang_tidy_aspect_impl(target, ctx):
    # if not a C/C++ target, we are not interested
    if not CcInfo in target:
        return []

    toolchain_flags = _toolchain_flags(ctx)
    rule_flags = ctx.rule.attr.copts if hasattr(ctx.rule.attr, "copts") else []
    safe_flags = _safe_flags(toolchain_flags + rule_flags)
    compilation_context = target[CcInfo].compilation_context
    srcs = _rule_sources(ctx)

    fixes = []
    logs = []
    for src in srcs:
        fix, log = _run_tidy(ctx, safe_flags, compilation_context, src)
        fixes.append(fix)
        logs.append(log)

    return [OutputGroupInfo(fixes = depset(fixes), logs = depset(logs))]

clang_tidy_aspect = aspect(
    implementation = _clang_tidy_aspect_impl,
    fragments = ["cpp"],
    attrs = {
        "_cc_toolchain": attr.label(default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")),
        "_clang_tidy": attr.label(default = Label("//:clang_tidy")),
        "_clang_tidy_config": attr.label(default = Label("//:clang_tidy_config")),
    },
)

def _clang_tidy_test_impl(ctx):
    files = depset(
        transitive = [
            target[OutputGroupInfo].logs
            for target in ctx.attr.targets
        ] + [
            target[OutputGroupInfo].fixes
            for target in ctx.attr.targets
        ],
    )
    ctx.actions.symlink(
        output = ctx.outputs.executable,
        target_file = ctx.attr._clang_tidy_check[DefaultInfo].files_to_run.executable,
    )
    runfiles = ctx.runfiles(files.to_list())
    return DefaultInfo(runfiles = runfiles)

clang_tidy_test = rule(
    implementation = _clang_tidy_test_impl,
    attrs = {
        "targets": attr.label_list(
            providers = [CcInfo],
            aspects = [clang_tidy_aspect],
        ),
        "_clang_tidy_check": attr.label(
            executable = True,
            cfg = "host",
            default = "//:clang_tidy_check",
        ),
    },
    test = True,
)
