{ runCommand

, pesto

, bash
, clang
, coreutils
, diffutils
, findutils
, gnused
, clangFormatConfig ? builtins.path {
    name = "clang-format";
    path = ./.clang-format;
  }
}:
let
  src =
    runCommand
      "clang_format"
      {
        inherit bash clang coreutils diffutils findutils gnused;
      }
      ''
        mkdir -p $out
        cp ${./BUILD} $out/BUILD
        cp ${clangFormatConfig} $out/.clang-format
        cp ${./clang_format.bzl} $out/clang_format.bzl
        substituteAll ${./clang_format.sh} $out/clang_format.sh
        substituteAll ${./clang_format_check.sh} $out/clang_format_check.sh
        chmod +x $out/*.sh
      '';
in
rec {
  name = "clang_format";
  inherit src;
  deps = [ ];
  symlink = "ln -nsfv ${src} external/${name}";
  workspace = pesto.lib.newLocalRepository name "BUILD";
}
