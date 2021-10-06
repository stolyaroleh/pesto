set -ue

fixes=$1
shift
logs=$1
shift

PATH="$PATH:@coreutils@/bin:@gnused@/bin:@clang@/bin"

cp "external/clang_tidy/.clang-tidy" .

# clang-tidy doesn't create a patchfile if there are no errors.
# Make sure the output exists, and empty if there are no errors,
# so the build system will not be confused.
touch "$fixes" "$logs"
truncate -s 0 "$fixes" "$logs"

# Strip exec root prefix to make all paths in generated reports relative.
clang-tidy --export-fixes="$fixes" "$@" 2>&1 | sed "s|$(readlink -f $(pwd))\/||" > "$logs" || true
sed -i "s|$(readlink -f $(pwd))\/||" "$fixes"
