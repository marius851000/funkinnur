{ nicePkgs ? import <nixpkgs> { }
, pkgs ? import
    (builtins.fetchTarball {
      url = "https://github.com/marius851000/nixpkgs/archive/3ec053e2d1ddedd1be2c2ab2acfce29d4df86c97.tar.gz";
      sha256 = "sha256:05l41scfx6lzzam804qd2nbqja7m37xb0w5fvjay1grs6rrlsnzb";
    })
    { }
}:

let
  build = pkgs.callPackage ./nixtool/build.nix {};
in
  build ./mods/vs-impostor
  #build (builtins.fromJSON (builtins.readFile ./mods/smoke-em-out-struggle/game.json))