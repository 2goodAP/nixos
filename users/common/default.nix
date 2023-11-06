# Configurations shared across the various user profiles.
{pkgs, ...}: {
  tgap.user = {
    desktop.applications.enable = true;
    programs.enable = true;
  };

  home.packages = with pkgs; [
    sway
    hyprland
    wmenu
    wofi
    foot
  ];
}
