{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop.hyprland;
  inherit (lib) mkIf;
in
  mkIf cfg.enable {
    programs = {
      eww = {
        enable = true;
        package = pkgs.eww-wayland;
        configDir = ./eww;
      };
    };

    services = {
      blueman-applet.enable = true;
      network-manager-applet.enable = true;
    };
  }
