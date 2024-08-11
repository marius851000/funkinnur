{
  description = "Flake utils demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "nixpkgs";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = import ./test.nix { inherit pkgs; };
      in
      rec {
        inherit packages;
        defaultPackage = packages.smoke-em-out-struggle;
      } // (if system == "x86_64" then {
        hydraJobs = packages;
      } else {})
    );
}