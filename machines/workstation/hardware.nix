{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    kernelModules = ["kvm-intel"];
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
    kernelParams = ["split_lock_detect=off"];

    initrd = {
      kernelModules = ["dm-snapshot"];
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
    };
  };

  hardware = {
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;

    nvidia = {
      open = false;
      modesetting.enable = true;
      nvidiaPersistenced = true;

      package = let
        inherit (lib) concatStrings splitVersion;
      in
        config.boot.kernelPackages.nvidiaPackages.mkDriver rec {
          version = "550.40.82";
          persistencedVersion = "550.54.14";
          settingsVersion = "550.54.14";
          sha256_64bit = "sha256-+lvADY8k3Wfc1wuDLHC8xP1BPK/la3ZJmHvZ3zqQJ+I=";
          openSha256 = "sha256-wTNAMI3J83v3lhKJ1yKgrL2V+mzLr3MeCT7oLlEasFw=";
          settingsSha256 = "sha256-m2rNASJp0i0Ez2OuqL+JpgEF0Yd8sYVCyrOoo/ln2a4=";
          persistencedSha256 = "sha256-XaPN8jVTjdag9frLPgBtqvO/goB5zxeGzaTU0CdL6C4=";
          url =
            "https://developer.nvidia.com/downloads/"
            + "vulkan-beta-${concatStrings (splitVersion version)}-linux";
        };

      powerManagement = {
        enable = true;
        finegrained = true;
      };

      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        reverseSync.enable = true;
      };
    };
  };

  services = {
    hardware.bolt.enable = true;
    xserver.videoDrivers = ["nvidia"];
  };
}
