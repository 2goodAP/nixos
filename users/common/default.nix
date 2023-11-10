# Configurations shared across the various user profiles.
{pkgs, ...}: {
  tgap.home = {
    desktop = {
      applications.enable = true;
      hyprland.enable = true;
    };
    programs.enable = true;
  };
}
