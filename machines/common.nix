# Configurations shared across the various nixos profiles for laptops.
{
  hardware.bluetooth.enable = true;

  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
  };

  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
    };

    # Enable CUPS for printing documents.
    printing.enable = true;
  };
}
