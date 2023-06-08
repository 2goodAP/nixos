# Configurations shared across the various nixos profiles.
{...}: {
  tgap.system = {
    audio.enable = true;
    apparmor.enable = true;
    bluetooth.enable = true;
    plasma5.enable = true;

    programs = {
      enable = true;
      fd.enable = true;
      glow.enable = true;
      neovim.enable = true;
      ripgrep.enable = true;
      qmk.enable = true;
      virtualisation.enable = true;
    };
  };
}
