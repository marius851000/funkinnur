{
  stdenv,
  pname,
  version,
  src,
  renameBinary ? pname,

  psych_engine,

  makeWrapper
}:

stdenv.mkDerivation {
  inherit pname version src;

  buildPhase = "";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib/${pname}
    cp -r ${psych_engine}/lib/psych-engine/* $out/lib/${pname}
    mkdir -p $out/lib/${pname}/mods
    ln -s ${src} $out/lib/${pname}/mods/${pname}
    echo "${pname}|1" > $out/lib/${pname}/modsLists.txt

    ln -s $out/lib/${pname}/mods/${pname}/data $out/lib/${pname}/mods/data
    chmod u+w -R $out/lib/${pname}/assets/data/
    ln -s $out/lib/${pname}/mods/${pname}/data/* $out/lib/${pname}/assets/data/
    
    mkdir -p $out/bin/

    makeWrapper "$out/lib/${pname}/PsychEngine-nocd" $out/bin/${renameBinary} \
      --run "cd $out/lib/${pname}"
  '';
}