PATH="$PATH:@findutils@/bin"

red() {
  COLOR='\033[1;31m' # red
  NO_COLOR='\033[0m'
  echo -e "${COLOR}$*${NO_COLOR}"
}

has_errors=0

for log in $(find . -iname "*.clang-format.log"); do
  f="${log%%.clang-format.log}"
  if [[ -s $log ]]; then
    has_errors=1
    red "$f"
    cat "${f}.clang-format.log"
  fi
done

exit $has_errors
