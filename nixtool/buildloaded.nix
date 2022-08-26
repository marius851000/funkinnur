{ callPackage }:

let
  buildsourcemod = callPackage ./buildsourcemod.nix {};

  varioustool = callPackage ./various.nix {};

  getsource = callPackage ./source.nix {};

  getsourceversion = callPackage ./sourceversion.nix {};
in
{
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
    src = getsource source;
  };
in
if type == "sourcemod" then buildsourcemod args else throw "unknown type of mod " + type

