{
  description = "2goodAP's NixOS configuration with flakes.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
    self,
    nixpkgs,
    flake-parts,
    nur,
    home-manager,
    nbfc-linux,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      flake.nixosConfigurations = let
        inherit (nixpkgs) lib;
        overlays = import ./overlays;
        system = "x86_64-linux";
        systemModules = import ./modules/system;
      in {
        nitro5 = lib.nixosSystem {
          inherit system;

          modules = [
            # Custom system modules.
            systemModules

            # Home-Manager modules.
            home-manager.nixosModules.home-manager

            # nix and nixpkgs specific settings.
            {
              nix.settings = {
                experimental-features = ["nix-command" "flakes"];
                max-jobs = 12;

                substituters = [
                  "https://cache.nixos.org/"
                ];
                trusted-public-keys = [
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                ];
              };

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
            (import ./machines/nitro5 {
              hostName = "nitro5-nix";
              inherit nur;
            })
          ];
        };

        workstation = lib.nixosSystem {
          inherit system;

          modules = [
            # Custom system modules.
            systemModules

            # Home-Manager modules.
            home-manager.nixosModules.home-manager

            # nix and nixpkgs specific settings.
            {
              nix.settings = {
                experimental-features = ["nix-command" "flakes"];
                max-jobs = 28;

                substituters = [
                  "https://cache.nixos.org/"
                  "https://cuda-maintainers.cachix.org/"
                ];
                trusted-public-keys = [
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                  "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
                ];
              };

              nixpkgs = {
                config.allowUnfree = true;
                inherit overlays;
              };
            }

            # System-specific configuraitons.
            (import ./machines/workstation {
              hostName = "workstation-nix";
              inherit nur;
            })
          ];
        };
      };
    };
}
