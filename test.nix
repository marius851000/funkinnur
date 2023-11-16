{ pkgs ? import <nixpkgs> {}}:

let
  build = pkgs.callPackage ./nixtool/build.nix {};
in
{
  vs-rainbow = build ./mods/vs-rainbow;

  smoke-em-out-struggle = build ./mods/smoke-em-out-struggle;

  vs-impostor = build ./mods/smoke-em-out-struggle;

  psych-engine = build ./mods/psych-engine-0.6.x;

  psych-engine-05x = build ./mods/psych-engine-0.5.x;

  dusk-till-dawn = build ./mods/dusk-till-dawn;
}