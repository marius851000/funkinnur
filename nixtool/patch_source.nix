{ stdenv, python3 }:

source:

stdenv.mkDerivation {
  name = "source-patched";

  dontUnpack = true;

  nativeBuildInputs = [ python3 ];

  buildPhase = ''
    python3 ${./patch_source.py} ${source} ./dest
  '';

  installPhase = ''
    mv dest $out
  '';
}