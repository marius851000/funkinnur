{ stdenv, python3 }:

json_path: source:

stdenv.mkDerivation {
  name = "json-extended";

  dontUnpack = true;

  nativeBuildInputs = [ python3 ];

  buildPhase = ''
    python3 ${./analyze_source.py} ${source} ${json_path} ./dest.json
  '';

  installPhase = ''
    cp ./dest.json $out
  '';
}