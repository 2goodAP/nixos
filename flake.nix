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
        overlays = import ./overlays;
      in {
        nixosConfigurations = let
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          nitro5 = lib.nixosSystem {
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
              (import ./machines/nitro5 {
                hostName = "nitro5-nix";
                inherit lib pkgs;
              })

              # Configure users and groups.
              {
                users.users = {
                  root = {
                    isSystemUser = true;
                    initialPassword = "NixOS-root.";
                  };

                  aashishp = {
                    isNormalUser = true;
                    initialPassword = "NixOS-aashishp.";
                    extraGroups = [
                      "audio"
                      "cups"
                      "disk"
                      "docker"
                      "networkmanager"
                      "nixbld"
                      "video"
                      "wheel"
                    ];
                  };

                  workerap = {
                    isNormalUser = true;
                    initialPassword = "NixOS-workerap.";
                    extraGroups = [
                      "audio"
                      "cups"
                      "disk"
                      "docker"
                      "networkmanager"
                      "nixbld"
                      "video"
                      "wheel"
                    ];
                  };

                  justagamer = {
                    isNormalUser = true;
                    initialPassword = "NixOS-justagamer.";
                    extraGroups = [
                      "audio"
                      "disk"
                      "networkmanager"
                      "video"
                      "wheel"
                    ];
                  };
                };
              }

              # Home-Manager configurations.
              home-manager.nixosModules.home-manager
              ({config, ...}: {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  sharedModules = [userModules];

                  extraSpecialArgs = {
                    sysDesktop = config.tgap.system.desktop.enable;
                    sysQmk = config.tgap.system.programs.qmk.enable;
                    sysStateVersion = config.system.stateVersion;
                  };

                  users = {
                    aashishp.imports = [./users/aashishp];
                    workerap.imports = [./users/workerap];
                    justagamer.imports = [./users/justagamer];
                  };
                };
              })
            ];
          };

          workstation = lib.nixosSystem {
            inherit system;

            modules = [
              # Custom modules.
              systemModules

              # nix and nixpkgs specific settings.
              {
                nix.settings.experimental-features = ["nix-command" "flakes"];

                nixpkgs = {
                  config.allowUnfree = true;
                  inherit overlays;
                };
              }

              # System-specific configuraitons.
              (import ./machines/workstation {
                hostName = "workstation-nix";
                inherit lib pkgs;
              })

              # Configure users and groups.
              {
                users.users = {
                  root = {
                    isSystemUser = true;
                    initialPassword = "NixOS-root.";
                  };

                  aashishp = {
                    isNormalUser = true;
                    initialPassword = "NixOS-aashishp.";
                    extraGroups = [
                      "audio"
                      "cups"
                      "disk"
                      "docker"
                      "networkmanager"
                      "nixbld"
                      "video"
                      "wheel"
                    ];
                  };

                  workerap = {
                    isNormalUser = true;
                    initialPassword = "NixOS-workerap.";
                    extraGroups = [
                      "audio"
                      "cups"
                      "disk"
                      "docker"
                      "networkmanager"
                      "nixbld"
                      "video"
                      "wheel"
                    ];
                  };

                  justagamer = {
                    isNormalUser = true;
                    initialPassword = "NixOS-justagamer.";
                    extraGroups = [
                      "audio"
                      "disk"
                      "networkmanager"
                      "video"
                      "wheel"
                    ];
                  };
                };
              }

              # Home-Manager configurations.
              home-manager.nixosModules.home-manager
              ({config, ...}: {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  sharedModules = [userModules];

                  extraSpecialArgs = {
                    sysDesktop = config.tgap.system.desktop.enable;
                    sysQmk = config.tgap.system.programs.qmk.enable;
                    sysStateVersion = config.system.stateVersion;
                  };

                  users = {
                    aashishp.imports = [./users/aashishp];
                    workerap.imports = [./users/workerap];
                    justagamer.imports = [./users/justagamer];
                  };
                };
              })
            ];
          };
        };
      };
    };
}
