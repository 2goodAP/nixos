{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.boot = let
    inherit (lib) mkOption types;
  in {
    type = mkOption {
      description = "The type of boot to perform.";
      type = types.enum ["encrypted-boot-btrfs"];
    };

    espMountPoint = mkOption {
      description = "The mount point of the ESP.";
      type = types.str;
      default = "/efi";
    };
  };

  config = let
    cfg = config.tgap.system.boot;
    inherit (lib) mkIf;
  in
    mkIf (cfg.type == "encrypted-boot-btrfs") {
      boot = {
        consoleLogLevel = 3;

        initrd = let
          bootKeyFile = "/boot/crypto_keyfile.bin";
        in {
          luks.devices = {
            boot_crypt = {
              allowDiscards = true;
              device = "/dev/disk/by-partlabel/LinuxBootPartition";
              fallbackToPassword = true;
              keyFile = bootKeyFile;
            };
            swap_crypt = {
              allowDiscards = true;
              device = "/dev/disk/by-partlabel/LinuxSwapPartition";
            };
            data_crypt = {
              allowDiscards = true;
              device = "/dev/disk/by-partlabel/LinuxDataPartition";
            };
          };

          secrets."${bootKeyFile}" = bootKeyFile;
        };

        kernelParams = [
          "quiet"
          "udev.log_level=3"
          "resume=/dev/mapper/swap_crypt"
        ];

        loader = {
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = cfg.espMountPoint;
          };

          grub = let
            gkbFile = "grub/colemak_dh.gkb";

            # Generate colemak_dh GRUB shell keyboard layout.
            grub-mkgkb = pkgs.runCommandLocal "grub-mkgkb" {} ''
              ${pkgs.ckbcomp}/bin/ckbcomp -layout us -variant colemak_dh \
                | ${pkgs.grub2_efi}/bin/grub-mklayout -o $out
            '';
          in {
            enable = true;
            efiSupport = true;
            devices = ["nodev"];
            enableCryptodisk = true;
            extraGrubInstallArgs = ["--removable" "--bootloader-id=GRUB"];
            extraEntries = ''
              if [ ''${grub_platform} == "efi" ]; then
                menuentry "UEFI Shell" --id "uefi-shell" {
                  search --no-floppy --file --set=root /shellx64.efi
                  insmod chain

                  chainloader /shellx64.efi
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
              keymap ($drive1)/@boot/${gkbFile}
            '';
            extraFiles."${gkbFile}" = "${grub-mkgkb}";
          };
        };
      };

      fileSystems = {
        "${cfg.espMountPoint}" = {
          device = "/dev/disk/by-partlabel/EFISystemPartition";
          fsType = "vfat";
        };

        "/boot" = {
          device = "/dev/mapper/boot_crypt";
          fsType = "btrfs";
          options = ["compress=lzo" "noatime" "subvol=@boot"];
        };

        "/boot/.snapshots" = {
          device = "/dev/mapper/boot_crypt";
          fsType = "btrfs";
          options = ["compress=lzo" "noatime" "subvol=@snapshots"];
        };

        "/" = {
          device = "/dev/mapper/data_crypt";
          fsType = "btrfs";
          options = ["compress=lzo" "noatime" "subvol=@"];
        };

        "/home" = {
          device = "/dev/mapper/data_crypt";
          fsType = "btrfs";
          options = ["compress=lzo" "noatime" "subvol=@home"];
        };

        "/var" = {
          device = "/dev/mapper/data_crypt";
          fsType = "btrfs";
          options = ["compress=lzo" "noatime" "subvol=@var"];
        };

        "/tmp" = {
          device = "/dev/mapper/data_crypt";
          fsType = "btrfs";
          options = ["compress=lzo" "noatime" "subvol=@tmp"];
        };

        "/.snapshots" = {
          device = "/dev/mapper/data_crypt";
          fsType = "btrfs";
          options = ["compress=lzo" "noatime" "subvol=@snapshots"];
        };
      };

      swapDevices = [{device = "/dev/mapper/swap_crypt";}];
    };
}
