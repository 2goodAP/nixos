{
  lib,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ./apps.nix
    ./display.nix
    ./sway.nix
    ./theme.nix
    ./widgets.nix
  ];

  options.tgap.home.desktop.wayland = let
    inherit (lib) mkOption types;
  in {
    windowManager = mkOption {
      type = types.enum ["sway"];
      default = "sway";
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
    inherit (lib) mkIf;
  in
    mkIf (osCfg.enable && osCfg.manager == "wayland") {
      gtk = {
        enable = true;

        iconTheme = {
          name = "Papirus";
          package = pkgs.papirus-icon-theme;
        };
      };

      home = {
        packages = [pkgs.bibata-cursors];

        pointerCursor = {
          gtk.enable = true;
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
          size = 32;
        };
      };

      qt = {
        enable = true;
        platformTheme = "qtct";
      };
    };
}
