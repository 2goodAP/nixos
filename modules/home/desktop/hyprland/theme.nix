{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop.hyprland;
  inherit (lib) mkIf;
in
  mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        dim_inactive = true;
        dim_strength = 0.1;
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
        blur = {
          enabled = true;
          xray = true;
          size = 3;
          passes = 1;
        };
      };

      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
    };

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

    qt = {
      enable = true;
      platformTheme = "qtct";
      style = {
        name = "Materia Light";
        package = pkgs.materia-kde-theme;
      };
    };

    home = {
      packages = [pkgs.wallust];

      pointerCursor = {
        gtk.enable = true;
        name = "Bibata Modern Ice";
        package = pkgs.bibata-cursors;
        size = 28;
      };
    };
  }
