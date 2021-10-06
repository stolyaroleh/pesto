{ stdenvNoCC, gnused, python3 }:
stdenvNoCC.mkDerivation {
  name = "bazel-compdb";
  src = (import ../../nix/sources.nix).bazel-compilation-database;
  patches = [ ./bazel-compdb.patch ];
  phases = [ "unpackPhase" "patchPhase" "installPhase" "fixupPhase" ];

  buildInputs = [ python3 ];

  inherit gnused;
  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out
    substituteAll ${./generate-compilation-database} $out/bin/generate-compilation-database
    chmod +x $out/bin/generate-compilation-database
  '';
}
