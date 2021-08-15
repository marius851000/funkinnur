{ callPackage, haxe_4_1 }:

{ ... } @ args:

callPackage ./base.nix ( {
    haxe = haxe_4_1;
} // args )