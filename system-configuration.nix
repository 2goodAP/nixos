# System configurations for the various nixos profiles.
{
  config,
  pkgs,
  ...
}: {
  boot = {
    consoleLogLevel = 3;

    initrd = let
      bootKeyFile = "/boot/crypto_keyfile.bin";
    in {
      kernelModules = ["i915"];

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

      grub = let
        gkbFile = "grub/colemak_dh.gkb";

        # Generate colemak_dh GRUB shell keyboard layout.
        grub-mkgkb = pkgs.runCommandLocal "grub-mkgkb" {} ''
          ${pkgs.ckbcomp}/bin/ckbcomp -layout us -variant colemak_dh \
            | ${pkgs.grub2_efi}/bin/grub-mklayout -o $out
        '';
      in {
        enable = true;
        devices = ["nodev"];
        efiSupport = true;
        enableCryptodisk = true;
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
    "/efi" = {
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

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
    modesetting.enable = true;
    nvidiaPersistenced = true;
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    powerManagement.enable = true;
  };

  # Set time zone.
  time.timeZone = "Asia/Kathmandu";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-d18n.psf.gz";
    useXkbConfig = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11";
}
