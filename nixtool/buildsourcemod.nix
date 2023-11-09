{
  stdenv, lib, callPackage, xdg-utils,

  # default buildInputs
  alsaLib, libpulseaudio, libGL, libX11, libXdmcp, libXext, libXi, libXinerama, libXrandr, luajit,

  # default nativeBuildInputs
  haxe, neko, makeWrapper, haxePackages,
}:

let
  extraLibs = callPackage ./haxelibs.nix { };
in
{
  name,
  pname,
  result_binary_name,
  version,
  src,
  source_folder ? "source",
  export_folder ? "export",
  built_binary_name,
  patches ? [],
  ...
} @ args:
let
  apiFile = builtins.toFile "APIStuff.hx"
  ''
    package;

    class APIStuff
    {
      public static var API:String = "";
      public static var EncKey:String = "";
    }
  '';

  varioustool = callPackage ./various.nix {};

  installmetafile = callPackage ./installmetafile.nix {};
in
stdenv.mkDerivation rec {
  inherit pname version src patches;

  buildInputs = [alsaLib libpulseaudio libGL libX11 libXdmcp libXext libXi libXinerama libXrandr luajit ];

  nativeBuildInputs = [ haxe neko makeWrapper ]
    ++ (with haxePackages; [
      hxcpp
      extraLibs.hscript
      extraLibs.openfl
      extraLibs.lime
      extraLibs.flixel
      extraLibs.flixel-addons
      extraLibs.flixel-ui
      extraLibs.newgrounds
      extraLibs.polymod
    ]);
  
  postPatch = ''
    if test ! -f ${source_folder}/APIStuff.hx; then
      # Real API keys are stripped from repo
      cp ${apiFile} ${source_folder}/APIStuff.hx
    fi
  '';

  enableParallelBuilding = true;

  #TODO: this could be enhanced to support more system
  #TODO: also, caching by building compilation in unit like crate2nix (if possible -- which I doubt given how haxe work)
  
  buildPhase = ''
    export HXCPP_COMPILE_CACHE=/tmp/hxcpp-cache
    export HXCPP_CACHE_MB=8000

    runHook preBuild

    export HOME=$PWD
    if test $enableParallelBuilding; then
      HXCPP_COMPILE_THREADS=$NIX_BUILD_CORES
    else
      HXCPP_COMPILE_THREADS=1
    fi

    haxelib run lime build linux

    runHook postBuild
  ''; #TODO: -final

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/${pname}}
    cp -R ${export_folder}/release/linux/bin/* $out/lib/${pname}/
    #$STRIP -s "$out/lib/${pname}/${built_binary_name}"
    #$STRIP -s "$out/lib/${pname}/lime.ndll"
    mv "$out/lib/${pname}/${built_binary_name}" "$out/lib/${pname}/${built_binary_name}-nocd"

    wrapProgram "$out/lib/${pname}/${built_binary_name}-nocd" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
    makeWrapper "$out/lib/${pname}/${built_binary_name}-nocd" "$out/lib/${pname}/${built_binary_name}" \
      --run "cd $out/lib/${pname}"
    ln -s "$out/lib/${pname}/${built_binary_name}" $out/bin/${result_binary_name}

    ${installmetafile args}

    runHook postInstall
  '';
}

