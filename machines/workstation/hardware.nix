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
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
      open = false;
      modesetting.enable = true;
      nvidiaPersistenced = true;
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
