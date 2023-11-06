{
  description = "2goodAP's NixOS configuration with flakes.";

  inputs = {
    hyprland.url = "github:hypr/Hyprland";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
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
    flake-parts,
    home-manager,
    nbfc-linux,
    nixpkgs,
    nixpkgs-wayland,
    nur,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      flake.nixosConfigurations = let
        inherit (nixpkgs) lib;
        overlays = import ./overlays ++ [nixpkgs-wayland.overlay];
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
                  "https://cuda-maintainers.cachix.org/"
                  "https://nixpkgs-wayland.cachix.org/"
                ];
                trusted-public-keys = [
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                  "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
                  "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
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
                  "https://nixpkgs-wayland.cachix.org/"
                ];
                trusted-public-keys = [
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                  "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
                  "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
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
