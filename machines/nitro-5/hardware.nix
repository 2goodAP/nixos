{
  pkgs,
  lib,
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

    kernelParams = [
      "quiet"
      "loglevel=3"
      "lsm=landlock,lockdown,yama,apparmor,bpf"
      "resume=/dev/mapper/swap_crypt"
    ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };
}
