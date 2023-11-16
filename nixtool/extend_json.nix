{ stdenv, python3 }:

json_path: source:

stdenv.mkDerivation {
  name = "json-extended";

  src = source;

  nativeBuildInputs = [ python3 ];

  buildPhase = ''
    python3 ${./analyze_source.py} ./ ${json_path} ./dest.json
  '';

  installPhase = ''
    cp ./dest.json $out
  '';
}