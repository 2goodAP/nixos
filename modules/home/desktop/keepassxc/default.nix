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
    home.packages = [pkgs.keepassxc];

    xdg.configFile.keepassxc-settings = {
      source = ./keepassxc.ini;
      target = "keepassxc/keepassxc.ini";
    };
  }
