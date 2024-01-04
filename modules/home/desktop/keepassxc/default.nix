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
      text = ''
        [FdoSecrets]
        Enabled=${if (osCfg.manager == "wayland") then "true" else "false"}

        ${builtins.readFile ./keepassxc.ini}
      '';
      target = "keepassxc/keepassxc.ini";
    };
  }
