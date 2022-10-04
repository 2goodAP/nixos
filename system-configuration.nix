# System configurations for the various nixos profiles.

{ pkgs, ... }:


let
  bootKeyFile = "/boot/crypto_keyfile.bin";
  bootDevice = "/dev/disk/by-partlabel/LinuxBootPartition";

  # Write a helper script to generate new luks keyfiles
  # at a predetermined location.
  generateLuksKeys = pkgs.writeScriptBin "generate-luks-keys" ''
    # Generate keyfiles for the necessary drives
    # and set the appropriate permissions.
    dd bs=1024 count=4 if=/dev/random of=${bootKeyFile} iflag=fullblock
    chmod 600 ${bootKeyFile}

    # Add/Replace the keyfiles (in slot 7) for the necessary devices.
    ${pkgs.cryptsetup}/bin/cryptsetup luksKillSlot ${bootDevice} 7
    ${pkgs.cryptsetup}/bin/cryptsetup luksAddKey --key-slot 7 ${bootDevice} ${bootKeyFile}

    # Regenerate the NixOS configuration to apply the new keyfiles.
    nixos-rebuild switch -I nixos-config=$HOME/.nixos/configuration.nix
  '';
in {
  environment.systemPackages = [generateLuksKeys];

  boot = {
    consoleLogLevel = 3;

    initrd = {
      kernelModules = [ "i915" ];
      
      luks.devices = {
        boot_crypt = {
          allowDiscards = true;
          device = bootDevice;
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

    kernelPackages = pkgs.linuxKernel.packages.linux_zen;

    kernelParams = [
      "quiet"
      "udev.log_level=3"
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
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
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
