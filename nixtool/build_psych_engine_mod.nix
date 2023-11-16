{ stdenv, callPackage, makeWrapper }:

let
  installmetafile = callPackage ./installmetafile.nix {};

  renameBinary = "todo";

  #src = /home/marius/dusk-till-dawn;

  psych_engine = (callPackage ./build.nix {}) ../mods/psych-engine-0.6.x;
in
{
  name,
  pname,
  version,
  src,
  patches ? [],
  ...
} @ args:
stdenv.mkDerivation {
  inherit pname version src patches;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${pname}
    cp -r --reflink=auto ${psych_engine}/lib/Psych-Engine/* $out/lib/${pname}
    mkdir -p $out/lib/${pname}/mods
    chmod -R +w $out/
    ln -s ${src} $out/lib/${pname}/mods/${pname}
    echo "${pname}|1" > $out/lib/${pname}/modsLists.txt

    ln -s $out/lib/${pname}/mods/${pname}/data $out/lib/${pname}/mods/data
    chmod u+w -R $out/lib/${pname}/assets/data/
    ln -s $out/lib/${pname}/mods/${pname}/data/* $out/lib/${pname}/assets/data/
    
    mkdir -p $out/bin/

    makeWrapper "$out/lib/${pname}/PsychEngine-nocd" $out/bin/${renameBinary} \
      --run "cd $out/lib/${pname}"

    ${installmetafile args}

    runHook postInstall
  '';
}