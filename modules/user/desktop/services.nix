{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.machine.desktop;
  inherit (lib) mkIf mkEnableOption mkOption types;
in {
  options.machine.desktop.services.wob = {
    enable = mkEnableOption {
      description = "Whether or not to enable wob.";
      default = false;
    };

    systemdTarget = mkOption {
      description = "Systemd target to bind to.";
      type = types.str;
      default = "graphical-session.target";
    };
  };

  config =
    mkIf (
      cfg.sway.enable
      && (builtins.getEnv "WAYLAND_DISPLAY" != "")
    ) {
      systemd = {
        services.wob = {
          inherit (cfg.services.wob) enable;
          description = "A lightweight overlay volume/backlight/progress/anything bar for Wayland";
          documentation = "man:wob(1)";
          partOf = [cfg.services.wob.systemdTarget];
          after = [cfg.services.wob.systemdTarget];
          serviceConfig = {
            StandardInput = "socket";
            ExecStart = "${pkgs.wob}/bin/wob";
          };
          wantedBy = [cfg.services.wob.systemdTarget];
        };

        sockets.wob = {
          inherit (cfg.services.wob) enable;
          socketConfig = {
            ListenFIFO = "%t/wob.sock";
            SocketMode = 0600;
          };
          wantedby = [cfg.services.wob.systemdTarget];
        };
      };
    };
}
