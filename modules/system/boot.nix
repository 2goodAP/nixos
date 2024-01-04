{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.boot = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    secureBoot.enable = mkEnableOption "Whether or not to enable UEFI secure boot.";

    encrypted-btrfs = {
      enable = mkEnableOption "Whether or not to enable encrypted btrfs partitions.";

      root = {
        partlabel = mkOption {
          type = types.str;
          default = "LinuxDataPart";
          description = "Partlabel for the root partition.";
        };

        extraPartlabels = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Partlabels for extra partitions to use as root.";
        };

        mountPoints = mkOption {
          type = types.listOf types.attrs;
          default = [
            {
              name = "/";
              subvol = "@";
            }
            {
              name = "/nix";
              subvol = "@nix";
            }
            {
              name = "/var";
              subvol = "@var";
            }
            {
              name = "/home";
              subvol = "@home";
            }
            {
              name = "/tmp";
              subvol = "@tmp";
            }
          ];
          description = ''
            A list containing attrsets of mount points and their corresponding brtfs subvolumes.
          '';
        };
      };

      esp = {
        partlabel = mkOption {
          type = types.str;
          default = "LinuxEFIPart";
          description = "Partlabel for the EFI system partition.";
        };

        mountPoint = mkOption {
          type = types.str;
          default = "/boot";
          description = "Mount point of the EFI system partition.";
        };
      };

      swap.partlabel = mkOption {
        type = types.str;
        default = "LinuxSwapPart";
        description = "Partlabel for the encrypted swap partition.";
      };

      zram.writeBackDev.partlabel = mkOption {
        type = types.str;
        default = "LinuxZramWritebackPart";
        description = "Partlabel for the encrypted zram writeback device.";
      };
    };
  };

  config = let
    cfg = config.tgap.system.boot;
    inherit (lib) mkForce mkIf mkMerge optionalAttrs;
  in
    mkIf cfg.encrypted-btrfs.enable (mkMerge [
      {
        boot = {
          consoleLogLevel = 3;
          plymouth.enable = true;

          initrd = mkMerge [
            {
              systemd.enable = true;

              luks.devices = mkMerge [
                {
                  "${cfg.encrypted-btrfs.root.partlabel}" = {
                    allowDiscards = true;
                    device = "/dev/disk/by-partlabel/${cfg.encrypted-btrfs.root.partlabel}";
                  };

                  "${cfg.encrypted-btrfs.swap.partlabel}" = {
                    allowDiscards = true;
                    device = "/dev/disk/by-partlabel/${cfg.encrypted-btrfs.swap.partlabel}";
                  };

                  "${cfg.encrypted-btrfs.zram.writeBackDev.partlabel}" = {
                    allowDiscards = true;
                    device = "/dev/disk/by-partlabel/${cfg.encrypted-btrfs.zram.writeBackDev.partlabel}";
                  };
                }

                (mkIf (builtins.length cfg.encrypted-btrfs.root.extraPartlabels > 0) (
                  builtins.listToAttrs (map (pl: {
                      name = pl;
                      value = {
                        allowDiscards = true;
                        device = "/dev/disk/by-partlabel/${pl}";
                      };
                    })
                    cfg.encrypted-btrfs.root.extraPartlabels)
                ))
              ];
            }
          ];

          kernelParams = [
            "quiet"
            "udev.log_level=3"
            "resume=/dev/mapper/${cfg.encrypted-btrfs.swap.partlabel}"
          ];

          loader = {
            timeout = 1;

            efi = {
              canTouchEfiVariables = true;
              efiSysMountPoint = cfg.encrypted-btrfs.esp.mountPoint;
            };

            systemd-boot = {
              enable = true;
              editor = false;
              extraFiles."efi/uefi-shell/shell.efi" = "${pkgs.edk2-uefi-shell}/shell.efi";
              memtest86.enable = true;

              extraEntries = {
                "uefi-shell.conf" = ''
                  title UEFI-Shell
                  efi /efi/uefi-shell/shell.efi
                '';
              };
            };
          };
        };

        fileSystems = mkMerge [
          {
            "${cfg.encrypted-btrfs.esp.mountPoint}" = {
              device = "/dev/disk/by-partlabel/${cfg.encrypted-btrfs.esp.partlabel}";
              fsType = "vfat";
              options = ["defaults" "noatime" "umask=0077"];
            };
          }

          (builtins.listToAttrs (map (mp: {
              inherit (mp) name;
              value = {
                device = "/dev/mapper/${cfg.encrypted-btrfs.root.partlabel}";
                fsType = "btrfs";
                options = [
                  "defaults"
                  "compress-force=zstd"
                  "noatime"
                  "nodiscard"
                  "subvol=${mp.subvol}"
                ];
              };
            })
            cfg.encrypted-btrfs.root.mountPoints))
        ];

        swapDevices = [
          {
            device = "/dev/mapper/${cfg.encrypted-btrfs.swap.partlabel}";
            priority = 0;
          }
        ];
        zramSwap = {
          enable = true;
          priority = 10;
          writebackDevice = "/dev/mapper/${cfg.encrypted-btrfs.zram.writeBackDev.partlabel}";
        };
      }

      (mkIf cfg.secureBoot.enable {
        environment.systemPackages = [pkgs.sbctl];

        boot = {
          loader.systemd-boot.enable = mkForce false;
          lanzaboote = {
            enable = true;
            pkiBundle = "/etc/secureboot";
          };
        };
      })
    ]);
}
