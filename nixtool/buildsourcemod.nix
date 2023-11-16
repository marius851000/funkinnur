{
  stdenv, lib, callPackage, xdg-utils,

  # default buildInputs
  alsaLib, libpulseaudio, libGL, libX11, libXdmcp, libXext, libXi, libXinerama, libXrandr, luajit,

  # default nativeBuildInputs
  haxe, neko, makeWrapper, haxePackages,

  # extra
  libvlc
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
  modules ? {},
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

  getsource = callPackage ./source.nix {};

  getsourceversion = callPackage ./sourceversion.nix {};
  
  modules_default = {
    "linc_luajit" = {
      enabled = false;
      package = extraLibs.linc_luajit;
    };
    "discord_rpc" = {
      enabled = false;
      package = extraLibs.discord_rpc;
    };
    "hxcodec" = {
      enabled = false;
      package = builtins.trace "${extraLibs.hxcodec}" extraLibs.hxcodec;
    };
    "vlc" = {
      enabled = false;
      package = (libvlc.override { lua5 = null; }).overrideAttrs (old: {
        configureFlags = old.configureFlags ++ [ "--disable-lua" ];
      });
    };
  };

  modules_to_use = lib.mapAttrs (
    name: value:
      if (modules ? "${name}") || (value.enabled) then
        let
          module_user_conf = modules."${name}";
        in
          if (if module_user_conf ? enabled then module_user_conf.enabled else true) then
            value // {
              enabled = true;
              package = value.package.overrideAttrs (old: {
                src = if module_user_conf ? source then
                  getsource module_user_conf.source
                else
                  old.src;
                name = if module_user_conf ? source then
                  (name + "-" + (getsourceversion module_user_conf.source))
                else
                  if old ? name then old.name else "${old.pname}-${old.version}";
              });
            }
          else
            (value // {
              enabled = false;
            })
      else
        value
      /*haxePackages.buildHaxeLib {
        libname = name;
        version = getsourceversion value.source;
        src = getsource value.source;
        meta = {};
      }*/
    )
    modules_default;
in
stdenv.mkDerivation rec {
  inherit pname version src patches;

  buildInputs = [ alsaLib libpulseaudio libGL libX11 libXdmcp libXext libXi libXinerama libXrandr luajit ];

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
      extraLibs.extension-webm # should not be included by default (actually, it should parse required deps in the extend json phase)
      extraLibs.actuate
    ]) ++
    (
      lib.mapAttrsToList (key: value: if value.enabled then value.package else null)
      (modules_to_use)
    );
  
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
    find

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

