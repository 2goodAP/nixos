{
  config,
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
      package = config.boot.kernelPackages.nvidiaPackages.beta;

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
