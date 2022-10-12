# Service configurations for the various nixos profiles.

{ ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };


  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
  };


  services = {
    ntp.enable = true;
    timesyncd.enable = true;
    openssh.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
    };

    printing.enable = true;
    tlp.enable = true;
    usbmuxd.enable = true;
  };
}
