{
  lib,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ./apps.nix
    ./display.nix
    ./overlays.nix
    ./sway.nix
    ./theme.nix
    ./widgets.nix
  ];

  options.tgap.home.desktop.wayland = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    windowManager = mkOption {
      type = types.enum ["hyprland" "sway"];
      default = "hyprland";
      description = "The wayland window manager to use.";
    };

    systemdTarget = mkOption {
      type = types.str;
      default = "graphical-session.target";
      description = "The systemd target to bind wayland services to.";
    };

    socks.sov = mkOption {
      type = types.str;
      default = "sov.sock";
      description = "The FIFO buffer name for the sov systemd socket.";
    };
  };

  config = let
    osCfg = osConfig.tgap.system.desktop;
    inherit (lib) getExe getExe' mkIf;
  in
    mkIf (osCfg.enable && osCfg.manager == "wayland") {
      gtk = {
        enable = true;

        iconTheme = {
          name = "Papirus";
          package = pkgs.papirus-icon-theme;
        };
      };

      home.pointerCursor = {
        gtk.enable = true;
        name = "Bibata Modern Ice";
        package = pkgs.bibata-cursors;
        size = 28;
      };

      qt = {
        enable = true;
        platformTheme = "qtct";
      };
    };
}
