{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      kernelModules = ["dm-snapshot" "i915"];
    };

    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;

    nvidia = {
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
  };

  services = {
    undervolt = {
      enable = true;
      temp = 95;
      coreOffset = -150;
      uncoreOffset = -150;
    };
    xserver.videoDrivers = ["nvidia"];
  };
}
