# System configurations for the various nixos profiles.

{ pkgs, ... }:

{
  boot = {
    initrd = {
      kernelModules = [ "i915" ];
      
      luks.devices = {
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
    };

    kernelPackages = pkgs.linuxKernel.packages.linux_zen;

    kernelParams = [
      "quiet"
      "loglevel=3"
      "lsm=landlock,lockdown,yama,apparmor,bpf"
      "resume=/dev/mapper/swap_crypt"
    ];

    # Use the GRUB EFI boot loader.
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
      
      grub = {
        devices = [ "nodev" ];
        efiSupport = true;
        enable = true;
        enableCryptodisk = true;
        extraGrubInstallArgs = [ "--bootloader-id=GRUB" ];
      };
    };
  };


  fileSystems = {
    "/efi" = {
      device = "/dev/disk/by-partlabel/EFISystemPartition";
      fsType = "vfat";
    };

    "/boot" = {
      device = "/dev/mapper/boot_crypt";
      fsType = "btrfs";
      options = [ "autodefrag" "compress=lzo" "noatime" "subvol=@boot" ];
    };

    "/boot/.snapshots" = {
      device = "/dev/mapper/boot_crypt";
      fsType = "btrfs";
      options = [ "autodefrag" "compress=lzo" "noatime" "subvol=@snapshots" ];
    };

    "/" = {
      device = "/dev/mapper/data_crypt";
      fsType = "btrfs";
      options = [ "autodefrag" "compress=lzo" "noatime" "subvol=@" ];
    };

    "/home" = {
      device = "/dev/mapper/data_crypt";
      fsType = "btrfs";
      options = [ "autodefrag" "compress=lzo" "noatime" "subvol=@home" ];
    };

    "/var" = {
      device = "/dev/mapper/data_crypt";
      fsType = "btrfs";
      options = [ "autodefrag" "compress=lzo" "noatime" "subvol=@var" ];
    };

    "/tmp" = {
      device = "/dev/mapper/data_crypt";
      fsType = "btrfs";
      options = [ "autodefrag" "compress=lzo" "noatime" "subvol=@tmp" ];
    };

    "/.snapshots" = {
      device = "/dev/mapper/data_crypt";
      fsType = "btrfs";
      options = [ "autodefrag" "compress=lzo" "noatime" "subvol=@snapshots" ];
    };
  };


  swapDevices = [ { device = "/dev/mapper/swap_crypt"; } ];


  # Set time zone.
  time.timeZone = "Asia/Kathmandu";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";


  console = {
    font = "Lat2-Terminus18";
    keyMap = "us";
    packages = [ pkgs.terminus_font ];
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05";
}
