{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop;
  osCfg = osConfig.services.xserver.desktopManager.plasma5;
  inherit (lib) mkIf;
in
  mkIf (osCfg.enable && cfg.applications.enable) {
    home = {
      packages = [pkgs.speedcrunch];

      file.speedcrunch-settings = {
        source = ./SpeedCrunch.ini;
        target = ".config/SpeedCrunch/SpeedCrunch.ini";
      };
    };
}
