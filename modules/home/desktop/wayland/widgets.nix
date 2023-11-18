{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  osCfg = osConfig.tgap.system.desktop;
  inherit (lib) mkIf;
in
  mkIf (osCfg.enable && osCfg.manager == "wayland") {
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
