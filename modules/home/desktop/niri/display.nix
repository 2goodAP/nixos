{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop;
  osCfg = osConfig.tgap.system;
  inherit (lib) getExe getExe' mkIf optionals;
in
  mkIf (osCfg.desktop.enable && osCfg.desktop.manager == "niri" && cfg.enable) {
    home.packages = with pkgs; [
      wlr-randr
      xwayland-satellite
    ];

    programs = {
      hyprlock.enable = true;
      wlogout.enable = true;
    };

    services = {
      shikane.enable = true;

      swayidle = {
        enable = true;

        events = [
          {
            event = "before-sleep";
            command = "${getExe pkgs.hyprlock}";
          }
          {
            event = "lock";
            command = "${getExe pkgs.hyprlock}";
          }
        ];
        timeouts =
          [
            {
              timeout = 15 * 60;
              command = "${getExe pkgs.hyprlock}";
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

    systemd.user.services.xwayland-satellite = let
      systemdTarget = config.wayland.systemd.target;
    in {
      Install.WantedBy = [systemdTarget];

      Service = {
        Type = "notify";
        NotifyAccess = "all";
        ExecStart = getExe pkgs.xwayland-satellite;
        StandardOutput = "journal";
      };

      Unit = {
        Description = "Xwayland outside your Wayland";
        BindsTo = [systemdTarget];
        PartOf = [systemdTarget];
        After = [systemdTarget];
        Requisite = [systemdTarget];
      };
    };
  }
