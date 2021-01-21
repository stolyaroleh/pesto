{ runCommand
, clang
, coreutils
, findutils
, gnused
, clangTidyConfig ? null
}:
let
  copyConfig =
    if clangTidyConfig == null
    then "touch $out/.clang-tidy"
    else "cp ${clangTidyConfig} $out/.clang-tidy";
  src =
    runCommand
      "clang_tidy"
      {
        inherit clang coreutils findutils gnused;
      }
      ''
        mkdir -p $out
        cp ${./BUILD} $out/BUILD
        ${copyConfig}
        cp ${./clang_tidy.bzl} $out/clang_tidy.bzl
        substituteAll ${./clang_tidy.sh} $out/clang_tidy.sh
        substituteAll ${./clang_tidy_check.sh} $out/clang_tidy_check.sh
        chmod +x $out/*.sh
      '';
in
rec {
  name = "clang_tidy";
  inherit src;
  deps = [ ];
  symlink = "ln -nsfv ${src} external/${name}";
}
