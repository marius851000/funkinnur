{ pkgs ? import <nixpkgs> {}}:

let
  buildFNFMod = pkgs.callPackage 