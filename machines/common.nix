# Configurations shared across the various nixos profiles.
{...}: {
  tgap.system = {
    audio.enable = true;
    apparmor.enable = true;
    bluetooth.enable = true;
    plasma5.enable = true;

    programs = {
      enable = true;
      android-tools.enable = true;
      fd.enable = true;
      glow.enable = true;
      qmk.enable = true;
      ripgrep.enable = true;
      virtualisation.enable = true;

      neovim = {
        enable = true;
        treesitter = {
          enable = true;
          extraPlugins.enable = true;
        };
      };
    };
  };
}
