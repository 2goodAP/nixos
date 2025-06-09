{
  description = "2goodAP's NixOS configuration with flakes.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:YaLTer/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    umu-launcher = {
      url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    woomer = {
      url = "github:coffeeispower/woomer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    home-manager,
    lanzaboote,
    nixpkgs,
    nur,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({withSystem, ...}: {
      systems = ["x86_64-linux"];

      flake.nixosConfigurations = let
        systemModules = [
          # nixos settings
          ({
            config,
            inputs',
            lib,
            ...
          }: {
            nixpkgs = {
              config.allowUnfree = true;
              overlays = import ./overlays {inherit config inputs inputs' lib;};
            };

            home-manager = {
              backupFileExtension = "hm.bak";
              extraSpecialArgs = {inherit inputs';};
              useGlobalPkgs = true;
              useUserPackages = true;
              users.root = import ./users/common/programs.nix;

              sharedModules = [
                # custom home-manager modules
                (import ./modules/home)
              ];
            };

            nix.settings = {
              experimental-features = ["nix-command" "flakes"];
              max-jobs = 12;

              substituters = [
                "https://cache.nixos.org"
                "https://cuda-maintainers.cachix.org"
                "https://ghostty.cachix.org"
                "https://hyprland.cachix.org"
                "https://nix-community.cachix.org"
                "https://nixpkgs-wayland.cachix.org"
              ];
              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
                "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
                "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
              ];
            };

            users.users.root = {
              createHome = true;
              isSystemUser = true;
              initialPassword = "NixOS-root.";
            };
          })

          # external nixos modules
          home-manager.nixosModules.home-manager
          lanzaboote.nixosModules.lanzaboote
          nur.modules.nixos.default

          # custom nixos modules
          (import ./modules/system)
        ];

        # Create users and home-manager profiles.
        justagamer = import ./users/justagamer;
        twogoodap = import ./users/twogoodap;
        workerap = import ./users/workerap;
      in
        builtins.mapAttrs (sysName: userModules:
          withSystem "x86_64-linux" ({
            inputs',
            system,
            ...
          }:
            nixpkgs.lib.nixosSystem {
              specialArgs = {inherit inputs';};

              modules =
                systemModules
                ++ [
                  # Added to fix the build error:
                  # 'nixpkgs.hostPlatform or nixpkgs.system not set'
                  {nixpkgs.hostPlatform = {inherit system;};}

                  # system-specific configurations
                  (import ./machines/workstation {hostName = "${sysName}-nix";})
                ]
                ++
                # user-specific configurations
                userModules;
            })) {
          nitro5 = [twogoodap workerap];
          workstation = [twogoodap workerap justagamer];
        };
    });
}
