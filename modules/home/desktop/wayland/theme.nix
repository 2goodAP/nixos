{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop.wayland;
  osCfg = osConfig.tgap.system.desktop;
  inherit (lib) mkIf;
in
  mkIf (osCfg.enable && osCfg.manager == "wayland") {
    home.packages = [pkgs.wallust];

    xdg.configFile.wallust-settings = {
      source = ./wallust;
      target = "wallust";
      recursive = true;
    };
  }
