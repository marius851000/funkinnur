{
  description = "Flake utils demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:marius851000/nixpkgs/a1cbf607e96b4971ae3716f90913cad70df73195";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      rec {
        packages = import ./default.nix { inherit pkgs; nicePkgs = null; };
        defaultPackage = packages.friday-night-funkin;
      }
    );
}