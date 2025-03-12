{
  config,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = ["kvm-intel"];

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
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
      powerManagement.enable = true;

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
    xserver.videoDrivers = ["nvidia"];

    undervolt = {
      enable = true;
      temp = 95;
      coreOffset = -150;
      uncoreOffset = -150;
    };
  };
}
