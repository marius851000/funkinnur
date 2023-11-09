{ callPackage }:

folder:

let
  buildloaded = callPackage ./buildloaded.nix {};

  getsource = callPackage ./source.nix {};

  extendJson = callPackage ./extend_json.nix {};

  patch_source = callPackage ./patch_source.nix {};

  baseJson = builtins.fromJSON (builtins.readFile "${folder}/game.json");

  source_unpatched = getsource baseJson.source;

  jsonPatchedDerivation = extendJson "${folder}/game.json" source_unpatched;

  json = builtins.fromJSON (builtins.readFile "${jsonPatchedDerivation}");

  json_fixed = json // {
    patches = if (json ? patches) then (
      builtins.map (x: "${folder}/${x}") json.patches
    ) else [];
  };

  source_patched = patch_source source_unpatched;
in
  buildloaded source_patched json_fixed