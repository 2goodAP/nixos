{
  description = "2goodAP's NixOS configuration with flakes."


  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    }
  };


  outputs = { self, flake-utils, nixpkgs, home-manager, ... }: 
  let
    localLib = import ./lib;
  in {
    nixosConfigurations.Nitro5 = localLib.mkSystem {
      inherit flake-utils, nixpkgs, home-manager;
    };
  }
}
