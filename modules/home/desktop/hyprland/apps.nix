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
      rofi = {
        enable = true;
        package = pkgs.rofi-wayland.override {
          plugins = [pkgs.rofimoji];
        };
      };
    };

    services = {
      playerctld.enable = true;

      cliphist = {
        enable = true;
        systemdTarget = "hyprland-session.target";
      };
    };

    home.packages = with pkgs; [
      hyprkeys
      hyprland-per-window-layout
      hyprpaper
      hyprpicker
      udiskie
      watershot
      wev
    ];
  }
