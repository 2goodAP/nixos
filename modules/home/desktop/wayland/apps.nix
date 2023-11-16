{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop.wayland;
  osCfg = osConfig.tgap.system.desktop;
  inherit (lib) mkIf optionals;
in
  mkIf (osCfg.enable && osCfg.manager == "wayland") {
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
        systemdTarget = cfg.systemdTarget;
      };
    };

    home.packages =
      (with pkgs; [
        udiskie
        wallust
        watershot
        wev
        wl-clipboard
      ])
      ++ (
        optionals (cfg.windowManager == "hyprland") (with pkgs; [
          hyprkeys
          hyprland-per-window-layout
          hyprpaper
          hyprpicker
        ])
      );
  }
