{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop.wayland;
  osCfg = osConfig.tgap.system;
  inherit (lib) getExe getExe' mkIf optionals;
in
  mkIf (osCfg.desktop.enable && osCfg.desktop.manager == "wayland") {
    home.packages = [pkgs.wlr-randr];

    programs = {
      swaylock.enable = true;
      wlogout.enable = true;
    };

    services = {
      kanshi = {
        enable = true;
        systemdTarget = cfg.systemdTarget;
      };

      swayidle = {
        enable = true;
        systemdTarget = cfg.systemdTarget;

        events = [
          {
            event = "after-resume";
            command = ''${getExe' pkgs.sway "swaymsg"} "output * power on"'';
          }
          {
            event = "before-sleep";
            command = "${getExe pkgs.swaylock} -efF";
          }
          {
            event = "lock";
            command = "${getExe pkgs.swaylock} -efF";
          }
        ];
        timeouts =
          [
            {
              timeout = 30;
              command = ''if ${getExe' pkgs.procps "pgrep"} -x swaylock; \
                then ${getExe' pkgs.sway "swaymsg"} "output * power off"; fi'';
            }
            {
              timeout = 13 * 60;
              command = ''${getExe' pkgs.sway "swaymsg"} "output * power off"'';
            }
            {
              timeout = 15 * 60;
              command = "${getExe pkgs.swaylock} -efF";
            }
          ]
          ++ (
            optionals osCfg.laptop.enable [
              {
                timeout = 20 * 60;
                command = "${getExe' pkgs.systemd "systemctl"} -i suspend";
              }
            ]
          );
      };
    };
  }
