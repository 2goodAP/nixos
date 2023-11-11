{
  description = "2goodAP's NixOS configuration with flakes.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    lanzaboote.url = "github:nix-community/lanzaboote";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nbfc-linux = {
      url = "github:nbfc-linux/nbfc-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/hyprland";
    hy3 = {
      url = "github:outfoxxed/hy3";
      inputs.hyprland.follows = "hyprland";
    };
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = {
    flake-parts,
    home-manager,
    lanzaboote,
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

        systemSettings = {
          nix.settings = {
            experimental-features = ["nix-command" "flakes"];
            max-jobs = 12;

            substituters = [
              "https://cache.nixos.org"
              "https://cuda-maintainers.cachix.org"
              "https://hyprland.cachix.org"
              "https://nixpkgs-wayland.cachix.org"
            ];
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
              "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
              "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
            ];
          };

          nixpkgs = {
            config.allowUnfree = true;
            inherit overlays;
          };
        };

        mkHomeSettings = {config, ...}: {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm.bak";

          sharedModules = [
            # NUR modules for `config.nur` options.
            nur.nixosModules.nur

            # Custom user modules.
            (import ./modules/home)
          ];

          extraSpecialArgs = {
            inherit inputs;
            sysPlasma5 = config.tgap.system.plasma5.enable;
            sysQmk = config.tgap.system.programs.qmk.enable;
            sysStateVersion = config.system.stateVersion;
          };
        };
      in {
        nitro5 = lib.nixosSystem {
          inherit system;

          modules = [
            # home-manager module
            home-manager.nixosModules.home-manager
            # lanzaboote nixos module
            lanzaboote.nixosModules.lanzaboote

            # nix and nixpkgs specific settings
            (lib.recursiveUpdate systemSettings {
              nixpkgs.overlays =
                overlays
                ++ [
                  (final: prev: {
                    nbfc-linux = nbfc-linux.defaultPackage.${system};
                  })
                ];
            })
            # custom system modules
            systemModules

            # system-specific configuraitons
            (import ./machines/nitro5 {
              hostName = "nitro5-nix";
              inherit mkHomeSettings;
            })
          ];
        };

        workstation = lib.nixosSystem {
          inherit system;

          modules = [
            # home-manager modules
            home-manager.nixosModules.home-manager
            # lanzaboote nixos module
            lanzaboote.nixosModules.lanzaboote

            # nix and nixpkgs specific settings
            systemSettings
            # custom system modules
            systemModules

            # system-specific configuraitons
            (import ./machines/workstation {
              hostName = "workstation-nix";
              inherit mkHomeSettings;
            })
          ];
        };
      };
    };
}
