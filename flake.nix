{
  description = "2goodAP's NixOS configuration with flakes.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
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
  };

  outputs = {
    flake-parts,
    home-manager,
    lanzaboote,
    nixpkgs,
    nur,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      flake.nixosConfigurations = let
        inherit (nixpkgs) lib;
        system = "x86_64-linux";

        systemModules = [
          ({
            config,
            lib,
            ...
          }: {
            nix.settings = {
              experimental-features = ["nix-command" "flakes"];
              max-jobs = 12;

              substituters = [
                "https://cache.nixos.org"
                "https://cuda-maintainers.cachix.org"
                "https://nixpkgs-wayland.cachix.org"
              ];
              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
                "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
              ];
            };

            nixpkgs = {
              config.allowUnfree = true;
              inherit (import ./overlays {inherit config inputs lib system;}) overlays;
            };
          })

          # external nixos modules
          home-manager.nixosModules.home-manager
          lanzaboote.nixosModules.lanzaboote

          # custom nixos modules
          (import ./modules/system)
        ];

        mkHomeSettings = {config, ...}: {
          backupFileExtension = "hm.bak";
          extraSpecialArgs = {inherit inputs;};
          useGlobalPkgs = true;
          useUserPackages = true;

          sharedModules = [
            # NUR modules for `config.nur` options.
            nur.nixosModules.nur

            # Custom user modules.
            (import ./modules/home)
          ];
        };
      in {
        nitro5 = lib.nixosSystem {
          inherit system;

          modules =
            systemModules
            ++ [
              # system-specific configuraitons
              (import ./machines/nitro5 {
                hostName = "nitro5-nix";
                inherit mkHomeSettings;
              })
            ];
        };

        workstation = lib.nixosSystem {
          inherit system;

          modules =
            systemModules
            ++ [
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
