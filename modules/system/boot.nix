{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.boot = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    useOSProber = mkEnableOption "Whether or not to enable grub os-prober.";
    secureBoot.enable = mkEnableOption "Whether or not to enable UEFI secure boot.";

    encrypted-btrfs = {
      enable = mkEnableOption "Whether or not to enable encrypted btrfs partitions.";

      root = {
        partlabel = mkOption {
          type = types.str;
          default = "LinuxDataPartition";
          description = "Partlabel for the partition to use for the root partition.";
        };

        extraPartlabels = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Partlabels for extra partitions to use for the root partition.";
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
              name = "/home";
              subvol = "@home";
            }
            {
              name = "/var";
              subvol = "@var";
            }
            {
              name = "/tmp";
              subvol = "@tmp";
            }
            {
              name = "/.snapshots";
              subvol = "@snapshots";
            }
          ];
          description = "A list containing attrsets of mount points and their corresponding brtfs subvolumes.";
        };
      };

      boot = {
        partlabel = mkOption {
          type = types.str;
          default = "LinuxBootPartition";
          description = "Partlabel for the partition to use for the boot partition.";
        };

        mountPoints = mkOption {
          type = types.listOf types.attrs;
          default = [
            {
              name = "/boot";
              subvol = "@boot";
            }
            {
              name = "/boot/.snapshots";
              subvol = "@snapshots";
            }
          ];
          description = "A list containing attrsets of mount points and their corresponding brtfs subvolumes.";
        };

        keyFile = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Path containing the keyfile for the encrypted boot partition.
            The keyfile will only work as intended if it is placed inside the boot partition.
          '';
        };
      };

      swap.partlabel = mkOption {
        type = types.str;
        default = "LinuxSwapPartition";
        description = "Partlabel for the partition to use for the swap partition.";
      };

      esp = {
        partlabel = mkOption {
          type = types.str;
          default = "LinuxEFIPartition";
          description = "Partlabel for the partition to use for the EFI system partition.";
        };

        mountPoint = mkOption {
          type = types.str;
          default = "/efi";
          description = "Mount point of the EFI system partition.";
        };
      };
    };
  };

  config = let
    cfg = config.tgap.system.boot;
    inherit (lib) mkForce mkIf mkMerge optionalAttrs traceVal;
  in
    mkIf cfg.encrypted-btrfs.enable {
      boot = mkMerge [
        {
          consoleLogLevel = 3;

          initrd = mkMerge [
            {
              systemd.enable = true;

              luks.devices = mkMerge [
                {
                  "${cfg.encrypted-btrfs.boot.partlabel}" =
                    {
                      allowDiscards = true;
                      device = "/dev/disk/by-partlabel/${cfg.encrypted-btrfs.boot.partlabel}";
                    }
                    // (
                      optionalAttrs (!builtins.isNull cfg.encrypted-btrfs.boot.keyFile) {
                        inherit (cfg.encrypted-btrfs.boot) keyFile;
                      }
                    );
                  "${cfg.encrypted-btrfs.swap.partlabel}" = {
                    allowDiscards = true;
                    device = "/dev/disk/by-partlabel/${cfg.encrypted-btrfs.swap.partlabel}";
                  };
                  "${cfg.encrypted-btrfs.root.partlabel}" = {
                    allowDiscards = true;
                    device = "/dev/disk/by-partlabel/${cfg.encrypted-btrfs.root.partlabel}";
                  };
                }

                (mkIf (builtins.length cfg.encrypted-btrfs.root.extraPartlabels != 0) (
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

            (mkIf (!builtins.isNull cfg.encrypted-btrfs.boot.keyFile) {
              secrets."${cfg.encrypted-btrfs.boot.keyFile}" = cfg.encrypted-btrfs.boot.keyFile;
            })
          ];

          kernelParams = [
            "quiet"
            "udev.log_level=3"
            "resume=/dev/mapper/${cfg.encrypted-btrfs.swap.partlabel}"
          ];

          loader = {
            efi = {
              canTouchEfiVariables = true;
              efiSysMountPoint = cfg.encrypted-btrfs.esp.mountPoint;
            };

            grub = let
              gkbFile = "colemak_dh.gkb";
              shellEFI = "shellx64.efi";

              # Generate colemak_dh GRUB shell keyboard layout.
              grub-mkgkb = pkgs.runCommandLocal "grub-mkgkb" {} ''
                ${pkgs.ckbcomp}/bin/ckbcomp -layout us -variant colemak_dh \
                  | ${pkgs.grub2_efi}/bin/grub-mklayout -o $out
              '';
            in {
              enable = true;
              efiSupport = true;
              useOSProber = cfg.useOSProber;
              devices = ["nodev"];
              enableCryptodisk = true;
              extraGrubInstallArgs = ["--removable" "--bootloader-id=GRUB"];
              extraEntries = ''
                if [ ''${grub_platform} == "efi" ]; then
                  menuentry "UEFI Shell" --id "uefi-shell" {
                    insmod fat
                    insmod chain

                    search --no-floppy --file --set=root ${shellEFI}
                    chainloader /${shellEFI}
                  }

                  menuentry "UEFI Firmware Settings" --id "uefi-firmware" {
                    fwsetup
                  }
                fi

                menuentry "Reboot" {
                  reboot
                }

                menuentry "Shutdown" {
                  halt
                }
              '';
              extraConfig = ''
                # Change the keyboard layout (for supported keyboards).
                insmod keylayouts

                terminal_input at_keyboard console

                search --no-floppy --file --set=root ${gkbFile}
                keymap /grub/${gkbFile}
              '';
              extraFiles."grub/${gkbFile}" = "${grub-mkgkb}";
            };
          };
        }

        (mkIf cfg.secureBoot.enable {
          loader.systemd-boot.enable = mkForce false;
          lanzaboote = {
            enable = true;
            pkiBundle = "/etc/secureboot";
          };
        })
      ];

      fileSystems = mkMerge [
        {
          "${cfg.encrypted-btrfs.esp.mountPoint}" = {
            device = "/dev/disk/by-partlabel/${cfg.encrypted-btrfs.esp.partlabel}";
            fsType = "vfat";
          };
        }

        (builtins.listToAttrs (map (mp: {
            inherit (mp) name;
            value = {
              device = "/dev/mapper/${cfg.encrypted-btrfs.boot.partlabel}";
              fsType = "btrfs";
              options = ["compress=zstd" "noatime" "space_cache=v2" "subvol=${mp.subvol}"];
            };
          })
          cfg.encrypted-btrfs.boot.mountPoints))

        (builtins.listToAttrs (map (mp: {
            inherit (mp) name;
            value = {
              device = "/dev/mapper/${cfg.encrypted-btrfs.root.partlabel}";
              fsType = "btrfs";
              options = ["compress=zstd" "noatime" "space_cache=v2" "subvol=${mp.subvol}"];
            };
          })
          cfg.encrypted-btrfs.root.mountPoints))
      ];

      swapDevices = [{device = "/dev/mapper/${cfg.encrypted-btrfs.swap.partlabel}";}];
    };
}
