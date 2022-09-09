{
  description = "2goodAP's NixOS configuration with flakes.";


  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, flake-utils, nixpkgs, home-manager, ... }:
  let
    lib = import ./lib;
    system = "x86_64-linux";
    modules = import ./modules;
    overlays = import ./overlays;
  # in flake-utils.lib.eachDefaultSystem (system: {
  in {
    nixosConfigurations.nitro5box = nixpkgs.lib.nixosSystem {
      inherit system;

      # Modules
      modules = [
        # Nix-specific configurations.
        {
          # Enable flakes.
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          nixpkgs = {
            # Allow un-free (propriatery) packages.
            config.allowUnfree = true;
            # Apply overlays
            inherit overlays;
          };
        }
        # System-specific configuraitons.
        ./systems/nitro-5
      ];
    };
  };
  # });
}
