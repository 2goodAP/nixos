{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      kernelModules = ["dm-snapshot"];
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
      open = true;
      modesetting.enable = true;
      nvidiaPersistenced = true;
      powerManagement.enable = true;
    };
  };

  services = {
    hardware.bolt.enable = true;
    xserver.videoDrivers = ["nvidia"];
  };
}
