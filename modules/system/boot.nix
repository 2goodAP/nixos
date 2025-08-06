{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.boot = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    secureBoot.enable = mkEnableOption "UEFI secure boot";
    rescue.enable = mkEnableOption "settings and kernel params for rescue";

    encrypted-btrfs = {
      enable = mkEnableOption "encrypted btrfs partitions";

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
          type = types.listOf (types.attrsOf types.str);
          default = [
            {
              name = "/";
              subvol = "@";
            }
            {
              name = "/home";
              subvol = "@home";
            }
            {
              name = "/tmp";
              subvol = "@tmp";
            }
            {
              name = "/var";
              subvol = "@var";
            }
          ];
          description = ''
            A list containing root mount points and
            their corresponding brtfs subvolumes.
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

      nix = {
        partlabel = mkOption {
          type = types.str;
          default = "LinuxNixPart";
          description = "Partlabel for the Nix partition.";
        };

        mountPoint = mkOption {
          type = types.str;
          default = "/nix";
          description = "Mount point of the Nix partition.";
        };
      };

      snapshots.mountPoints = mkOption {
        type = types.listOf (types.attrsOf types.str);
        default = [
          {
            name = "/home/.snapshots";
            subvol = "@snapshots/home";
          }
        ];
        description = ''
          A list containing snapshots mount points and
          their corresponding brtfs subvolumes.
        '';
      };

      swap.partlabel = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Partlabel for the encrypted swap partition.";
      };

      zramWriteBack.partlabel = mkOption {
        type = types.str;
        default = "LinuxZramWritebackPart";
        description = "Partlabel for the encrypted zram writeback device.";
      };
    };
  };

  config = let
    cfg = config.tgap.system.boot;
    ebCfg = cfg.encrypted-btrfs;
    swapPresent = !builtins.isNull ebCfg.swap.partlabel;
    inherit (lib) mkIf mkMerge optionalAttrs optionals;
  in
    mkIf ebCfg.enable (mkMerge [
      {
        boot =
          optionalAttrs (!cfg.rescue.enable) {consoleLogLevel = 3;}
          // {
            initrd = mkMerge [
              {
                systemd.enable = true;

                luks.devices =
                  {
                    ${ebCfg.root.partlabel} = {
                      allowDiscards = true;
                      device = "/dev/disk/by-partlabel/${ebCfg.root.partlabel}";
                    };

                    ${ebCfg.nix.partlabel} = {
                      allowDiscards = true;
                      device = "/dev/disk/by-partlabel/${ebCfg.nix.partlabel}";
                    };

                    ${ebCfg.zramWriteBack.partlabel} = {
                      allowDiscards = true;
                      device = "/dev/disk/by-partlabel/${ebCfg.zramWriteBack.partlabel}";
                    };
                  }
                  // optionalAttrs swapPresent {
                    ${ebCfg.swap.partlabel} = {
                      allowDiscards = true;
                      device = "/dev/disk/by-partlabel/${ebCfg.swap.partlabel}";
                    };
                  }
                  // optionalAttrs
                  (builtins.length ebCfg.root.extraPartlabels > 0)
                  (builtins.listToAttrs (map (pl: {
                      name = pl;
                      value = {
                        allowDiscards = true;
                        device = "/dev/disk/by-partlabel/${pl}";
                      };
                    })
                    ebCfg.root.extraPartlabels));
              }
            ];

            kernelParams =
              if cfg.rescue.enable
              then [
                "rescue"
                "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
              ]
              else
                [
                  "quiet"
                  "udev.log_level=3"
                ]
                ++ optionals swapPresent [
                  "resume=/dev/mapper/${ebCfg.swap.partlabel}"
                ];

            loader = {
              efi = {
                canTouchEfiVariables = true;
                efiSysMountPoint = ebCfg.esp.mountPoint;
              };

              systemd-boot = {
                enable =
                  if cfg.secureBoot.enable
                  then false
                  else true;
                configurationLimit = 10;
                editor =
                  if cfg.rescue.enable
                  then true
                  else false;
                edk2-uefi-shell.enable = true;
                memtest86.enable = true;
              };
            };

            plymouth = {
              enable =
                if cfg.rescue.enable
                then false
                else true;
              theme = "breeze";
            };
          };

        fileSystems =
          {
            ${ebCfg.esp.mountPoint} = {
              device = "/dev/disk/by-partlabel/${ebCfg.esp.partlabel}";
              fsType = "vfat";
              options = [
                "defaults"
                "relatime"
                "umask=0077"
              ];
            };

            ${ebCfg.nix.mountPoint} = {
              device = "/dev/mapper/${ebCfg.nix.partlabel}";
              fsType = "ext4";
              neededForBoot = true;
              options = [
                "defaults"
                "commit=60"
                "data=writeback"
                "errors=remount-ro"
                "journal_async_commit"
                "noatime"
                "nodiscard"
              ];
            };
          }
          // (builtins.listToAttrs (map ({
              name,
              subvol,
            }: {
              inherit name;
              value =
                {
                  device = "/dev/mapper/${cfg.encrypted-btrfs.root.partlabel}";
                  fsType = "btrfs";
                  options = [
                    "defaults"
                    "clear_cache"
                    "commit=60"
                    "compress-force=zstd"
                    "nodiscard"
                    "relatime"
                    "space_cache=v2"
                    "subvol=${subvol}"
                  ];
                }
                // optionalAttrs (builtins.elem name ["/" "/var"]) {
                  neededForBoot = true;
                };
            })
            (ebCfg.root.mountPoints
              ++ ebCfg.snapshots.mountPoints)));

        swapDevices = optionals swapPresent [
          {
            device = "/dev/mapper/${ebCfg.swap.partlabel}";
            priority = 0;
          }
        ];

        zramSwap = {
          enable = true;
          priority = 10;
          writebackDevice = "/dev/mapper/${ebCfg.zramWriteBack.partlabel}";
        };
      }

      (mkIf (!cfg.rescue.enable && cfg.secureBoot.enable) {
        environment.systemPackages = [pkgs.sbctl];

        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };
      })
    ]);
}
