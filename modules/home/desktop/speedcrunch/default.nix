{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop;
  osCfg = osConfig.tgap.system.desktop;
  inherit (lib) mkIf;
in
  mkIf (osCfg.enable && cfg.applications.enable) {
    home.packages = [pkgs.speedcrunch];

    xdg.configFile.speedcrunch-settings = {
      source = ./SpeedCrunch.ini;
      target = "SpeedCrunch/SpeedCrunch.ini";
    };
  }
