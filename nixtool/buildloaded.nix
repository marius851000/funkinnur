{ callPackage }:

let
  buildsourcemod = callPackage ./buildsourcemod.nix {};

  varioustool = callPackage ./various.nix {};

  getsourceversion = callPackage ./sourceversion.nix {};
in
src_parsed: {
  type,
  name,
  pname ? varioustool.sluggify name,
  result_binary_name ? pname,
  source,
  version ? getsourceversion source,
  patches ? [],
  ...
} @ argsBase:

let
  args = argsBase // {
    inherit pname result_binary_name version patches;
    src = src_parsed;
  };
in
if type == "sourcemod" then buildsourcemod args else throw "unknown type of mod " + type

