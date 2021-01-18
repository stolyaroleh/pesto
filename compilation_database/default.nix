{ stdenvNoCC, gnused }:
stdenvNoCC.mkDerivation {
  name = "bazel-compdb";
  src = (import ../nix/sources.nix).bazel-compilation-database;
  patches = [ ./bazel-compdb.patch ];
  phases = [ "unpackPhase" "patchPhase" "installPhase" "fixupPhase" ];

  inherit gnused;
  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/bin
    mv $out/bin/generate.sh $out/bin/.generate.sh
    substituteAll ${./generate-compilation-database} $out/bin/generate-compilation-database
    chmod +x $out/bin/generate-compilation-database
  '';
}
