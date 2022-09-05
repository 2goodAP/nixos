{
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      inherit efiSysMountPoint;
    };

    grub = {
      enable = true;
      efiSupport = true;
      devices = [ "nodev" ];
      extraGrubInstallArgs = [ "--bootloader-id=GRUB" ];
    };
  };
}
