{ callPackage }:

folder:

let
  buildloaded = callPackage ./buildloaded.nix {};

  json = builtins.fromJSON (builtins.readFile "${folder}/game.json");

  json_fixed = json // {
    patches = if (json ? patches) then (
      builtins.map (x: "${folder}/${x}") json.patches
    ) else [];
  };
in
  buildloaded json_fixed