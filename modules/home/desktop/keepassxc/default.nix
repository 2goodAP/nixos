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
  mkIf (osCfg.enable && cfg.enable && cfg.applications.enable) {
    home.packages = [pkgs.keepassxc];

    xdg.configFile.keepassxc-settings = {
      target = "keepassxc/keepassxc.ini";

      text =
        (builtins.readFile ./keepassxc.ini)
        + ''

          [FdoSecrets]
          Enabled=${
            if (osCfg.manager == "niri")
            then "true"
            else "false"
          }
        '';
    };
  }
