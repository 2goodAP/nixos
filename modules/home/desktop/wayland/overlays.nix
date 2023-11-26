{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop.wayland;
  osCfg = osConfig.tgap.system.desktop;
  inherit (lib) getExe mkIf mkMerge;
in
  mkIf (osCfg.enable && osCfg.manager == "wayland") (mkMerge [
    {
      home.packages = [pkgs.libnotify];

      programs.waybar = {
        enable = true;

        systemd = {
          enable = true;
          target = cfg.systemdTarget;
        };
      };

      services = {
        mako = {
          enable = true;
          borderRadius = 10;
          defaultTimeout = 10000;
          sort = "-priority";
        };

        swayosd = {
          enable = true;
        };
      };
    }

    (mkIf (cfg.windowManager == "sway") {
      systemd.user = {
        services.sov = {
          Install.WantedBy = [cfg.systemdTarget];

          Service = {
            Environment = "PATH=${pkgs.fontconfig}/bin:${pkgs.sway}/bin";
            ExecStart = "${getExe pkgs.sov}";
            StandardInput = "socket";
          };

          Unit = {
            Description = "An overlay that shows schemas for all workspaces to make navigation in sway easier";
            Documentation = "man:sov(1)";
            PartOf = ["graphical-session.target"];
            After = [cfg.systemdTarget];
            ConditionEnvironment = "WAYLAND_DISPLAY";
          };
        };

        sockets.sov = {
          Install.WantedBy = ["sockets.target"];

          Socket = {
            ListenFIFO = "%t/${cfg.socks.sov}";
            SocketMode = "0600";
            RemoveOnStop = "on";
            # If sov exits due to invalid input, clear the FIFO buffer as there
            # can be more invalid inputs that can cause sov to crash further.
            FlushPending = "yes";
          };
        };
      };
    })
  ])
