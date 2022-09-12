{
  description = "2goodAP's NixOS configuration with flakes.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    lib = import ./lib;
    modules = import ./modules;
    overlays = import ./overlays;
  in {
    nixosConfigurations.nitro5box = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        # Custom modules.
        modules

        # Nix-specific settings.
        {
          nix.settings.experimental-features = ["nix-command" "flakes"];
        }

        # System-specific configuraitons.
        (import ./machines/nitro-5 {
          hostName = "nitro5box";
          pkgs = import nixpkgs {
            config.allowUnfree = true;
            inherit system overlays;
          };
          inherit (nixpkgs) lib;
        })
      ];
    };
  };
}
