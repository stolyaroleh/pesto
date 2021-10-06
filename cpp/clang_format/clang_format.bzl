def _run_clang_format(ctx, infile):
    clang_format = ctx.attr._clang_format
    clang_format_config = ctx.attr._clang_format_config

    logs = ctx.actions.declare_file(infile.basename + ".clang-format.log", sibling = infile)
    ctx.actions.run(
        inputs = depset(
            [infile],
            transitive = [clang_format_config[DefaultInfo].files],
        ),
        outputs = [logs],
        executable = clang_format[DefaultInfo].files_to_run,
        arguments = [logs.path, infile.path],
        mnemonic = "ClangFormat",
        progress_message = "Run clang-format on {}".format(infile.short_path),
    )
    return logs

def _rule_files(ctx):
    files = []
    if hasattr(ctx.rule.attr, "srcs"):
        for src in ctx.rule.attr.srcs:
            files += src.files.to_list()
    if hasattr(ctx.rule.attr, "hdrs"):
        for hdr in ctx.rule.attr.hdrs:
            files += hdr.files.to_list()
    return files

def _clang_format_aspect_impl(target, ctx):
    # if not a C/C++ target, we are not interested
    if not CcInfo in target:
        return []

    logs = []
    for f in _rule_files(ctx):
        logs.append(_run_clang_format(ctx, f))

    return [OutputGroupInfo(logs = depset(logs))]

clang_format_aspect = aspect(
    implementation = _clang_format_aspect_impl,
    attrs = {
        "_clang_format": attr.label(default = Label("//:clang_format")),
        "_clang_format_config": attr.label(default = Label("//:clang_format_config")),
    },
)

def _clang_format_test_impl(ctx):
    files = depset(
        transitive = [
            target[OutputGroupInfo].logs
            for target in ctx.attr.targets
        ],
    )
    ctx.actions.symlink(
        output = ctx.outputs.executable,
        target_file = ctx.attr._clang_format_check[DefaultInfo].files_to_run.executable,
    )
    runfiles = ctx.runfiles(files.to_list())
    return DefaultInfo(runfiles = runfiles)

clang_format_test = rule(
    implementation = _clang_format_test_impl,
    attrs = {
        "targets": attr.label_list(
            providers = [CcInfo],
            aspects = [clang_format_aspect],
        ),
        "_clang_format_check": attr.label(
            executable = True,
            cfg = "host",
            default = "//:clang_format_check",
        ),
    },
    test = True,
)
