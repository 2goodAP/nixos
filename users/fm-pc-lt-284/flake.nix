{
  description = "Home Manager configuration of fm-pc-lt-284";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nbfc-linux = {
      url = "github:nbfc-linux/nbfc-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixgl,
    nur,
    home-manager,
    nbfc-linux,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    username = "fm-pc-lt-284";
  in {
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        {
          # Let Home Manager install and manage itself.
          programs.home-manager.enable = true;

          nixpkgs = {
            config.allowUnfree = true;
            overlays = [
              nixgl.overlay
              (final: prev: {
                nbfc-linux = nbfc-linux.defaultPackages.${system};
              })
            ];
          };

          home = {
            inherit username;
            homeDirectory = "/home/${username}";
          };
        }

        # Input modules.
        nur.nixosModules.nur

        # Custom modules.
        ../../modules/home
        ./default.nix
      ];

      extraSpecialArgs.osConfig = {
        system.stateVersion = "24.05";

        tgap.system = {
          laptop.enable = true;
          desktop = {
            enable = true;
            gaming.enable = false;
            manager = "plasma";
          };
          programs = {
            defaultShell = "nu";
            iosTools.enable = true;
          };
        };
      };
    };
  };
}
