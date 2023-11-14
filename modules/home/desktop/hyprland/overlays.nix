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
    services = {
      mako.enable = true;
      swayosd.enable = true;
    };

    home.packages = [pkgs.libnotify];
  }
