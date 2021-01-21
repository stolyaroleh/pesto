#!/bin/bash

set -ue

logs=$1
shift

f=$1
shift

PATH="$PATH:@coreutils@/bin:@gnused@/bin:@clang@/bin:@diffutils@/bin"

ln -sf "external/clang_format/.clang-format"

# Strip exec root prefix to make all paths in generated reports relative.
diff -u "$f" <(clang-format -style=file "$f" 2>&1) | sed "s|$(readlink -f $(pwd))\/||" > "$logs" || true
