{
  hostName,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware.nix
    ../share
  ];

  # Bootloader
  machine = {
    boot.type = "encrypted-boot-btrfs";

    network = {
      enable = true;
      inherit hostName;
      nameservers = ["1.1.1.1" "9.9.9.9"];
      interfaces = ["wlp0s20f3" "enp7s0f1"];
    };

    programs.enable = true;
  };

  # Set time zone.
  time.timeZone = "Asia/Kathmandu";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # Enable ssh.
  services.openssh.enable = true;

  console = {
    font = "Lat2-Terminus18";
    keyMap = "us";
    packages = [pkgs.terminus_font];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "22.05";
}
