{
  description = "Home Manager configuration of fm-pc-lt-284";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nbfc-linux = {
      url = "github:nbfc-linux/nbfc-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
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
          nixpkgs = {
            config.allowUnfree = true;
            overlays = [
              (final: prev: {
                nbfc-linux = nbfc-linux.defaultPackages.${system};
              })
            ];
          };

          home = {
            inherit username;
            homeDirectory = "/home/${username}";
          };

          # Let Home Manager install and manage itself.
          programs.home-manager.enable = true;
        }

        # Input modules.
        nur.nixosModules.nur

        # Custom modules.
        ../../modules/user
        ./default.nix
      ];

      extraSpecialArgs = {
        sysPlasma5 = true;
        sysStateVersion = "22.11";
      };
    };
  };
}