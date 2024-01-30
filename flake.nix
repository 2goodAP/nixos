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
          # nixos settings
          {
            nixpkgs.config.allowUnfree = true;

            home-manager = {
              backupFileExtension = "hm.bak";
              extraSpecialArgs = {inherit inputs;};
              useGlobalPkgs = true;
              useUserPackages = true;

              sharedModules = [
                # nur modules for `config.nur` options
                nur.nixosModules.nur

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
                "https://nixpkgs-wayland.cachix.org"
              ];
              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
                "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
              ];
            };

            users.users.root = {
              createHome = true;
              isSystemUser = true;
              initialPassword = "NixOS-root.";
            };
          }

          # overlays
          ({
            config,
            lib,
            ...
          }: {
            nixpkgs = {
              inherit (import ./overlays {inherit config inputs lib system;}) overlays;
            };
          })

          # external nixos modules
          home-manager.nixosModules.home-manager
          lanzaboote.nixosModules.lanzaboote

          # custom nixos modules
          (import ./modules/system)
        ];

        # Create users and home-manager profiles.
        justagamer = import ./users/justagamer;
        twogoodap = import ./users/twogoodap;
        workerap = import ./users/workerap;
      in {
        nitro5 = lib.nixosSystem {
          inherit system;

          modules =
            systemModules
            ++ [
              # system-specific configuraitons
              (import ./machines/nitro5 {hostName = "nitro5-nix";})

              # user-specific configurations
              twogoodap
              workerap
            ];
        };

        workstation = lib.nixosSystem {
          inherit system;

          modules =
            systemModules
            ++ [
              # system-specific configuraitons
              (import ./machines/workstation {hostName = "workstation-nix";})

              # user-specific configurations
              justagamer
              twogoodap
              workerap
            ];
        };
      };
    };
}
