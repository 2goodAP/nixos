{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  osCfg = osConfig.tgap.system.desktop;
  inherit (lib) mkIf;
in
  mkIf (osCfg.enable && osCfg.manager == "wayland") {
    services = {
      mako.enable = true;
      swayosd.enable = true;
    };

    home.packages = [pkgs.libnotify];
  }
