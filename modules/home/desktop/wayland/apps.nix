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
    home.packages =
      (with pkgs; [
        pavucontrol
        watershot
        wev
        wl-clipboard
      ])
      ++ (optionals (cfg.windowManager == "hyprland") (with pkgs; [
        hyprkeys
        hyprland-per-window-layout
        hyprpaper
        hyprpicker
      ]));

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

      udiskie = {
        enable = true;
        settings = {
          icon_names.media = ["media-optical"];
          program_options.udisks_version = 2;
        };
      };
    };
  }
