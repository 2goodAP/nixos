{
  description = "2goodAP's NixOS configuration with flakes.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
    };

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
    self,
    flake-parts,
    nixpkgs,
    home-manager,
    nbfc-linux,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      flake = let
        inherit (nixpkgs) lib;
        systemModules = import ./modules/system;
        userModules = import ./modules/user;
        overlays = import ./overlays {};
      in {
        nixosConfigurations = {
          nitro5box = let
            system = "x86_64-linux";
            pkgs = nixpkgs.legacyPackages.${system};
          in
            lib.nixosSystem {
              inherit system;

              modules = [
                # Custom modules.
                systemModules

                # nix and nixpkgs specific settings.
                {
                  nix.settings.experimental-features = ["nix-command" "flakes"];
                  nixpkgs = {
                    config.allowUnfree = true;
                    overlays =
                      overlays
                      ++ [
                        (final: prev: {
                          nbfc-linux = nbfc-linux.defaultPackage.${system};
                        })
                      ];
                  };
                }

                # System-specific configuraitons.
                (import ./machines/nitro-5 {
                  hostName = "nitro5box";
                  inherit lib pkgs nbfc-linux;
                })

                # Home-Manager configurations.
                home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    sharedModules = [userModules];

                    # users = {
                    #   jdoe = import ./home.nix;
                    # };
                  };
                }
              ];
            };
        };
      };
    };

  # let
  #   lib = import ./lib;
  #   modules = import ./modules;
  #   overlays = import ./overlays;
  # in {
  #   nixosConfigurations.nitro5box = nixpkgs.lib.nixosSystem {
  #     inherit system;

  #     modules = [
  #       # Custom modules.
  #       modules

  #       # Nix-specific settings.
  #       {
  #         nix.settings.experimental-features = ["nix-command" "flakes"];
  #       }

  #       # System-specific configuraitons.
  #       (import ./machines/nitro-5 {
  #         hostName = "nitro5box";
  #         pkgs = import nixpkgs {
  #           config.allowUnfree = true;
  #           inherit system overlays;
  #         };
  #         inherit (nixpkgs) lib;
  #       })
  #     ];
  #   };
  # };
}
