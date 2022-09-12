{
  config,
  lib,
  ...
}: let
  cfg = config.machine.boot;
  inherit (lib) mkIf mkOption types;
in {
  options.machine.boot = {
    type = mkOption {
      description = "The type of boot to perform.";
      type = types.enum ["encrypted-boot-btrfs"];
      default = null;
    };

    espMountPoint = mkOption {
      description = "The mount point of the ESP.";
      type = types.str;
      default = "/efi";
    };
  };

  config = mkIf (cfg.type == "encrypted-boot-btrfs") {
    boot = {
      initrd.luks.devices = {
        boot_crypt = {
          allowDiscards = true;
          device = "/dev/disk/by-partlabel/LinuxBootPartition";
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

      loader = {
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = cfg.espMountPoint;
        };

        grub = {
          enable = true;
          efiSupport = true;
          devices = ["nodev"];
          extraGrubInstallArgs = ["--bootloader-id=GRUB"];
          enableCryptodisk = true;
          extraEntries = ''
            menuentry "Reboot" {
              reboot
            }

            menuentry "Shutdown" {
              halt
            }
          '';
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
        options = ["autodefrag" "compress=lzo" "noatime" "subvol=@boot"];
      };

      "/boot/.snapshots" = {
        device = "/dev/mapper/boot_crypt";
        fsType = "btrfs";
        options = ["autodefrag" "compress=lzo" "noatime" "subvol=@snapshots"];
      };

      "/" = {
        device = "/dev/mapper/data_crypt";
        fsType = "btrfs";
        options = ["autodefrag" "compress=lzo" "noatime" "subvol=@"];
      };

      "/home" = {
        device = "/dev/mapper/data_crypt";
        fsType = "btrfs";
        options = ["autodefrag" "compress=lzo" "noatime" "subvol=@home"];
      };

      "/var" = {
        device = "/dev/mapper/data_crypt";
        fsType = "btrfs";
        options = ["autodefrag" "compress=lzo" "noatime" "subvol=@var"];
      };

      "/tmp" = {
        device = "/dev/mapper/data_crypt";
        fsType = "btrfs";
        options = ["autodefrag" "compress=lzo" "noatime" "subvol=@tmp"];
      };

      "/.snapshots" = {
        device = "/dev/mapper/data_crypt";
        fsType = "btrfs";
        options = ["autodefrag" "compress=lzo" "noatime" "subvol=@snapshots"];
      };
    };

    swapDevices = [{device = "/dev/mapper/swap_crypt";}];
  };
}
