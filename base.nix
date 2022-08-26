# all the input are made in the callPackage
{
  stdenv,
  pname,
  version,
  src,
  binaryName,
  renameBinary ? binaryName,
  humanName,
  desktopOverride ? {},
  metaOverride ? {},
  extraBuildInputs ? [],
  buildInputs ? [ alsaLib libpulseaudio libGL libX11 libXdmcp libXext libXi libXinerama libXrandr luajit ] ++ extraBuildInputs,
  nativeBuildInputs ? [ haxe neko makeWrapper ]
    ++ (with haxePackages; [
      hxcpp
      hscript
      openfl
      lime
      flixel
      flixel-addons
      flixel-ui
      newgrounds
      polymod
      discord_rpc
      #linc_luajit
    ]) ++ extraBuildInputs,
  patches ? [],
  installIcon ? "",
  extraAttributes ? {},
  sourceFolder ? "source",
  exportFolder ? "export",

  # actual (default) dependancies
  lib, makeDesktopItem,

  # default buildInputs
  alsaLib, libpulseaudio, libGL, libX11, libXdmcp, libXext, libXi, libXinerama, libXrandr, luajit,

  # default nativeBuildInputs
  haxe, neko, makeWrapper, haxePackages, #TODO: rather than using haxePackages, instead, use each of their child to make it easier to override
}:

let 
  apiFile = builtins.toFile "APIStuff.h"
  ''
    package;

    class APIStuff
    {
      public static var API:String = "";
      public static var EncKey:String = "";
    }
  '';

  desktopItem = makeDesktopItem ({
    name = pname;
    exec = renameBinary;
    desktopName = humanName;
    categories = [ "Game" "ArcadeGame" ];
    icon = pname;
  } // desktopOverride);
in
stdenv.mkDerivation ({
  inherit pname version src buildInputs patches nativeBuildInputs installIcon;

  postPatch = ''
    if test ! -f ${sourceFolder}/APIStuff.hx; then
      # Real API keys are stripped from repo
      cp ${apiFile} ${sourceFolder}/APIStuff.hx
    fi
  '';

  enableParallelBuilding = true;


  buildPhase = ''
    runHook preBuild

    export HOME=$PWD
    if test $enableParallelBuilding; then
      HXCPP_COMPILE_THREADS=$NIX_BUILD_CORES
    else
      HXCPP_COMPILE_THREADS=1
    fi
    
    haxelib run lime build linux

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/${pname}}
    cp -R ${exportFolder}/release/linux/bin/* $out/lib/${pname}/
    $STRIP -s "$out/lib/${pname}/${binaryName}"
    $STRIP -s "$out/lib/${pname}/lime.ndll"
    mv "$out/lib/${pname}/${binaryName}" "$out/lib/${pname}/${binaryName}-nocd"

    wrapProgram "$out/lib/${pname}/${binaryName}-nocd" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
    makeWrapper "$out/lib/${pname}/${binaryName}-nocd" "$out/lib/${pname}/${binaryName}" \
      --run "cd $out/lib/${pname}"
    ln -s "$out/lib/${pname}/${binaryName}" $out/bin/${renameBinary}

    # desktop file
    mkdir -p $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications

    runHook installIcon
    runHook postInstall
  '';

  meta = with lib; {
    description = humanName;
  } // metaOverride;

} // extraAttributes)

