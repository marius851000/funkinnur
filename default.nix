{ nicePkgs ? import <nixpkgs> { }
, pkgs ? import
    (builtins.fetchTarball {
      url = "https://github.com/marius851000/nixpkgs/archive/ee6987f2eb188179b54d44c9bc37e75454915859.tar.gz";
      sha256 = "sha256:1axm5929clk3jh478cydxcd8fpnrfl0vhqfnwzksfvyc6kzj9fm1";
    })
    { }
}:

let
  mkFunkinMod = pkgs.callPackage ./mkFunkinMod.nix { };

  actuate = pkgs.haxePackages.buildHaxeLib {
    libname = "actuate";
    version = "1.8.9";
    sha256 = "sha256-hHUZqnaEXqWSFwQBxd/6r77evcJ8geDJl1CI5ohPUq4=";
    meta = {
      description = "Actuate is the best library for animating Haxe projects. Power through your everyday needs using no-nonsense, lightweight tweens, then extend when you need more, through the swappable custom actuator system";
    };
  };

  #TODO: enhance upstream haxe packaging

  withCommas = pkgs.lib.replaceChars [ "." ] [ "," ];

  installLibHaxe = { libname, version, files ? "*" }: ''
    mkdir -p "$out/lib/haxe/${withCommas libname}/${withCommas version}"
    echo -n "${version}" > $out/lib/haxe/${withCommas libname}/.current
    cp -dpR ${files} "$out/lib/haxe/${withCommas libname}/${withCommas version}/"
  '';

  extension-webm = pkgs.haxePackages.buildHaxeLib rec {
    libname = "extension-webm";
    version = "2021-06-02";
    src = pkgs.fetchFromGitHub {
      owner = "KadeDev";
      repo = "extension-webm";
      rev = "809fda4776b11dd4ba15002c68249600b8bc1db0";
      sha256 = "sha256-dhJVlAVUev9ZqDQyGbicbSVxP90L7liLBnMgwP/lzbk=";
    };

    buildInputs = [
      pkgs.haxePackages.lime
      pkgs.haxePackages.hxcpp
    ];

    preBuild = ''
      export HOME=$(mktemp -d)
      haxelib run lime rebuild . linux -64 -release
      find | grep ndll
      ls ..
    '';

    installPhase = ''
      runHook preInstall
      (
        ${installLibHaxe { inherit libname version; }}
      )
      runHook postInstall
    '';

    meta = {
      description = "WEBM for haxe ?";
    };
  };
in
#TODO: auto-detect binaryName
rec {
  inherit mkFunkinMod;

  friday-night-funkin = mkFunkinMod
    {
      pname = "friday-night-funkin";
      version = "unstable-2021-04-02";
      binaryName = "Funkin";
      humanName = "Friday Night Funkin";

      desktopOverride = {
        icon = "funkin";
      };

      src = pkgs.fetchFromGitHub {
        owner = "ninjamuffin99";
        repo = "Funkin";
        rev = "faaf064e37d5a150d8aba451d740eeb81bd2e974";
        sha256 = "053qbmib9nsgx63d0rcykky6284cixibrwq9rv1sqx2ghsdn78ff";
      };

      #TODO: auto-detect when then need to be applied
      patches = [
        # TODO remove when fix pushed
        # Fixes Freeplay crash on master
        (pkgs.fetchpatch {
          name = "check-if-response-result-is-actually-there.patch";
          url = "https://github.com/ninjamuffin99/Funkin/pull/412/commits/af62bdca4d70e06ea8b383ab5c9c6b3f5d8f087b.patch";
          sha256 = "1p9vzm7hkay8fzrd82hgrnafd0g5qi34brzv0hyjirryhni840fy";
        })
        # Fixes bugged version outdated version
        (pkgs.fetchpatch {
          name = "fix-the-update-check.patch";
          url = "https://github.com/ninjamuffin99/Funkin/pull/941/commits/996c9b6d89bf4447b1f39390bb6e8fb7d6a8c37c.patch";
          sha256 = "1m5b47y2pbdwdk5dsvgivq8705cz95n8imdckyg3r9jazhkrvh6k";
        })
        # Fix link opening
        (pkgs.fetchpatch {
          name = "Makes-the-donation-button-actually-work-on-Linux.patch";
          url = "https://github.com/ninjamuffin99/Funkin/pull/172.patch";
          sha256 = "1491fw52j5am5bg02v05y82njbdj1aqqdidxz36i4g6kcdy2x2iz";
        })
      ];

      installIcon = ''
        mkdir -p $out/share/icons/hicolor/16x16/apps
        mkdir -p $out/share/icons/hicolor/32x32/apps
        mkdir -p $out/share/icons/hicolor/64x64/apps
        mkdir -p $out/share/icons/hicolor/512x512/apps
        cp art/icon16.png $out/share/icons/hicolor/16x16/apps/funkin.png
        cp art/icon32.png $out/share/icons/hicolor/32x32/apps/funkin.png
        cp art/icon64.png $out/share/icons/hicolor/64x64/apps/funkin.png
        # the size of the icon is actually 600x600 px
        cp art/iconOG.png $out/share/icons/hicolor/512x512/apps/funkin.png
      '';
    };
  #TODO: complete meta

  smoke-em-out-struggle = mkFunkinMod {
    pname = "smoke-em-out-struggle";
    version = "unstable-2021-06-12";
    binaryName = "vsgarcello";
    humanName = "Smoke 'Em Out Struggle";

    src = pkgs.fetchFromGitHub {
      owner = "Rageminer996";
      repo = "Smoke-Em-Out-Struggle-Mod";
      rev = "9525bb6eeb7104b36fb88aeda5d559111e05ce6d";
      sha256 = "sha256-YG1lUJs+4FnB2ILzWyhq+qlYE63uzLEuwnb7IhBrtVQ=";
    };

    installIcon = ''
      mkdir -p $out/share/icons/hicolor/16x16/apps
      mkdir -p $out/share/icons/hicolor/32x32/apps
      mkdir -p $out/share/icons/hicolor/64x64/apps
      mkdir -p $out/share/icons/hicolor/512x512/apps
      cp art/garicon16.png $out/share/icons/hicolor/16x16/apps/smoke-em-out-struggle.png
      cp art/garicon32.png $out/share/icons/hicolor/32x32/apps/smoke-em-out-struggle.png
      cp art/garicon64.png $out/share/icons/hicolor/64x64/apps/smoke-em-out-struggle.png
      # the size of the icon is actually 600x600 px
      cp art/gariconOG.png $out/share/icons/hicolor/512x512/apps/smoke-em-out-struggle.png
    '';
  };

  vs-impostor = mkFunkinMod {
    pname = "vs-impostor";
    version = "unstable-2021-07-14";
    binaryName = "Kade Engine";
    renameBinary = "vsimpostor";
    humanName = "VS impostor";

    src = pkgs.fetchFromGitHub {
      owner = "Clowfoe";
      repo = "VS-Impostor-GIT";
      rev = "fc53096f79d0183da80019254a4aa20a0f1829eb";
      sha256 = "sha256-FhvNGAcxQuQAL0Bmb4j2+wITJ3tiT0Cz4v0h8n/3zo8=";
    };

    patches = [
      ./kade_replay_user.diff
    ]; #TODO: autoapply when required
  };

  vs-whitty = mkFunkinMod {
    pname = "vs-whitty";
    version = "unstable-2021-07-21";
    binaryName = "Kade Engine";
    renameBinary = "vswhitty";
    humanName = "VS Whitty";


    src = pkgs.fetchFromGitHub {
      owner = "KadeDev";
      repo = "vswhitty-public";
      rev = "25c700d454f0a76c796c1196fa1faa8de2875eaa";
      sha256 = "sha256-4EHfijwct0ux1BY0Np9yqDCUQDOayo4gCAyYxfwZmZ0=";
    };

    installIcon = ''
      mkdir -p $out/share/icons/hicolor/8x8/apps
      mkdir -p $out/share/icons/hicolor/16x16/apps
      mkdir -p $out/share/icons/hicolor/32x32/apps
      cp art/icon8.png $out/share/icons/hicolor/8x8/apps/vs-whitty.png
      cp art/icon16.png $out/share/icons/hicolor/16x16/apps/vs-whitty.png
      cp art/icon32.png $out/share/icons/hicolor/32x32/apps/vs-whitty.png
    '';

    patches = [
      ./kade_replay_user.diff
      ./vswhitty.diff
    ]; #TODO: autoapply when required
  };

  vs-myra = mkFunkinMod {
    pname = "vs-myra";
    version = "unstable-mirror-2021-08-14";
    binaryName = "Kade Engine";
    renameBinary = "vsmyra";
    humanName = "VS Myra";

    src = pkgs.fetchFromGitHub {
      owner = "marius851000";
      repo = "Mirror-VS-Myra";
      rev = "2539c53a548a34f7d643877e17a4d1b6df8af30e";
      sha256 = "sha256-8jTr3ivzyNDsaSaPjJr++k+IzaWuyDKY1QYM1bYECAk=";
    };

    sourceFolder = "sourcemyra";
    exportFolder = "exportmyra";

    patches = [ ./vsmyra.diff ];
  };

  softmod = mkFunkinMod {
    pname = "softmod";
    version = "unstable-2021-10-08";
    binaryName = "Soft Mod";
    renameBinary = "softmod";
    humanName = "Friday Night Funkin': Soft";

    src = pkgs.fetchFromGitHub {
      owner = "mattsodes1031";
      repo = "Softmod-Public";
      rev = "ee67115fc049bc819083d74f503aeebaa2d8e669";
      sha256 = "sha256-Dl/5Z7kmnCsmsMRBXXjHLomiCUKfy+YSCZFOtDi+nl4=";
    };

    patches = [
      ./softmod.diff
      ./kade_replay_user.diff
    ]; # the usual patch stuff

      installIcon = ''
        mkdir -p $out/share/icons/hicolor/8x8/apps
        mkdir -p $out/share/icons/hicolor/16x16/apps
        mkdir -p $out/share/icons/hicolor/32x32/apps
        mkdir -p $out/share/icons/hicolor/64x64/apps
        mkdir -p $out/share/icons/hicolor/128x128/apps
        mkdir -p $out/share/icons/hicolor/256x256/apps
        mkdir -p $out/share/icons/hicolor/512x512/apps
        cp art/icon8.png $out/share/icons/hicolor/8x8/apps/softmod.png
        cp art/icon16.png $out/share/icons/hicolor/16x16/apps/softmod.png
        cp art/icon32.png $out/share/icons/hicolor/32x32/apps/softmod.png
        cp art/icon64.png $out/share/icons/hicolor/64x64/apps/softmod.png
        cp art/icon128.png $out/share/icons/hicolor/128x128/apps/softmod.png
        cp art/icon256.png $out/share/icons/hicolor/256x256/apps/softmod.png
        cp art/icon512.png $out/share/icons/hicolor/512x512/apps/softmod.png
      '';
    };
  explorers_of_death = mkFunkinMod {
    pname = "explorers-of-death";
    version = "demo";
    binaryName = "PsychEngine";
    renameBinary = "explorers-of-death";
    humanName = "Friday Night Funkin': Explorers of Death [DEMO]";

    src = pkgs.fetchFromGitHub {
      owner = "Milo008";
      repo = "FNF-Explorers-of-Death-source-code";
      rev = "8d1c480528874c3e616519ec776193f24f07e99e";
      sha256 = "sha256-nODCg4ZlrDPDe/ET4br6bQaht8ybNQOLlk2OqTYhFbE=";
    };
  };
}
