{
  description = "2goodAP's NixOS configuration with flakes.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    flake-parts,
    nixpkgs,
    home-manager,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      flake = let
        inherit (nixpkgs) lib;
        systemModules = import ./modules/system;
        userModules = import ./modules/user;
        overlays = import ./overlays;
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

                # Nix-specific settings.
                {
                  nix.settings.experimental-features = ["nix-command" "flakes"];

                  nixpkgs.allowUnfree = true;
                  nixpkgs.overlays = overlays;
                }

                # System-specific configuraitons.
                (import ./machines/nitro-5 {
                  hostName = "nitro5box";
                  inherit lib pkgs;
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
