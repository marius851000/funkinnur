{ callPackage, haxe_4_1 }:

{ haxe ? haxe_4_1, ... } @ args:

callPackage ./base.nix ( {
    haxe = haxe;
} // args )