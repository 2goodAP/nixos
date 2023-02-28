{
  config,
  lib,
  pkgs,
  ...
}: {
  options.machine.desktop.sway = let
    inherit (lib) mkOption types;
  in {
    enable = mkOption {
      description = "Whether or not to enable swaywm and supporting programs.";
      type = types.bool;
      default = false;
    };

    extraPackages = mkOption {
      description = "Extra packages to install along with swaywm.";
      type = types.listOf types.package;
      default = [];
    };
  };

  config = let
    cfg = config.machine.desktop.sway;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      wayland.windowManager.sway = {
        enable = true;
        swyanag.enable = true;
        wrapperFeatures.gtk = true;
        extraSessionCommands = ''
          export XDG_SESSION_TYPE=wayland
          export XDG_SESSION_DESKTOP=sway
          export XDG_CURRENT_DESKTOP=sway
          export MOZ_ENABLE_WAYLAND=1
          export CLUTTER_BACKEND=wayland
          export QT_QPA_PLATFORM=wayland-egl
          export QT_WAYLAND_FORCE_DPI=physical
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          export ECORE_EVAS_ENGINE=wayland-egl
          export ELM_ENGINE=wayland_egl
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';
      };

      programs = {
        mako.enable = true;
        rofi = {
          enable = true;
          package = pkgs.rofi-wayland;
        };
        waybar = {
          enable = true;
          systemd = {
            enable = true;
            target = "sway-session.target";
          };
        };
      };
      machine.services.wob = {
        enable = true;
        systemdTarget = "sway-session.target";
      };

      services = {
        # Display
        gammastep = {
          enable = true;
          tray = true;
          settings = {
            general.adjustment-method = "wayland";
          };
        };
        kanshi.enable = true;

        # Locking
        swayidle.enable = true;
      };

      # Extra Packages
      home.packages = with pkgs;
        [
          # Bar
          libappindicator-gtk3
          # Desktop
          swaybg
          # Input
          clipman
          wev
          wl-clipboard
          ydotool
          # Locking
          swaylock
          # Screenshot
          sway-contrib.grimshot
          # Volume
          pkgs.pavucontrol
        ]
        ++ cfg.extraPackages;
    };
}
