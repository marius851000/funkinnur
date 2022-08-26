{ lib, makeDesktopItem }:

# output the appropriate desktop and icon file. Should be run in the root folder, output in $out.
{
  name,
  pname,
  result_binary_name,
  icons ? {},
  ...
}:

let
  desktopItem = makeDesktopItem {
    name = pname;
    exec = result_binary_name;
    desktopName = name;
    categories = [ "Game" "ArcadeGame" ];
    icon = pname;
  };
  
  installIcon = lib.concatStringsSep "\n"
    (lib.mapAttrsToList (
    key: value:
    let
      extension = lib.last (lib.splitString "." value);
    in
    ''
      echo installing the ${key}x${key} icon, with extension ${extension}
      mkdir -p $out/share/icons/hicolor/${key}x${key}/apps
      cp ${value} $out/share/icons/hicolor/${key}x${key}/apps/${pname}.${extension}
    ''
  ) icons);
in
''
  mkdir -p $out/share
  ln -s ${desktopItem}/share/applications $out/share/applications

  ${installIcon}
''