{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ./apps.nix
    ./display.nix
    ./hyprland.nix
    ./overlays.nix
    ./widgets.nix
  ];

  options.tgap.home.desktop.wayland = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    windowManager = mkOption {
      type = types.enum ["hyprland"];
      default = "hyprland";
      description = "The wayland window manager to use.";
    };

    systemdTarget = mkOption {
      type = types.str;
      default = "graphical-session.target";
      description = "The systemd target to bind wayland services to.";
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
        theme = {
          name = "Materia Light";
          package = pkgs.materia-theme;
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
        style = {
          name = "Materia Light";
          package = pkgs.materia-kde-theme;
        };
      };
    };
}
