PATH="$PATH:@findutils@/bin"

red() {
  COLOR='\033[1;31m' # red
  NO_COLOR='\033[0m'
  echo -e "${COLOR}$*${NO_COLOR}"
}

has_errors=0

for yaml in $(find . -iname "*.clang-tidy.yaml"); do
  f="${yaml%%.clang-tidy.yaml}"
  if [[ -s $yaml ]]; then
    has_errors=1
    red "$f"
    cat "${f}.clang-tidy.log"
  fi
done

exit $has_errors
