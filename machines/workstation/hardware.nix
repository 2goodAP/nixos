{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = ["dm-snapshot"];
    };

    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
    kernelModules = ["kvm-intel"];
  };

  hardware = {
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
          version = "550.40.75";
          persistencedVersion = "550.54.14";
          settingsVersion = "550.54.14";
          sha256_64bit = "sha256-Bgze1hx2gTKhchNHNVTnPnGOqpUe5UjNXJW5tVFi0wE=";
          openSha256 = "sha256-NnJ3AxLWg90WjoZ81vzjII/UT2RaERF4IEZp5bRgElk=";
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
