{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop.hyprland;
  hyprPkg = config.wayland.windowManager.hyprland.package;
  osCfg = osConfig.tgap.system.laptop;
  inherit (lib) getExe getExe' mkIf optionals;
in
  mkIf cfg.enable {
    home.packages = [pkgs.wlr-randr];

    programs = {
      swaylock.enable = true;
      wlogout.enable = true;
    };

    services = {
      kanshi = {
        enable = true;
        systemdTarget = "hyprland-session.target";
      };

      swayidle = {
        enable = true;
        systemdTarget = "hyprland-session.target";

        events = [
          {
            event = "after-resume";
            command = "${getExe' hyprPkg "hyprctl"} dispatch dpms on";
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
              # timeout = 13 * 60;
              timeout = 10;
              command = "${getExe' hyprPkg "hyprctl"} dispatch dpms off";
            }
            {
              # timeout = 15 * 60;
              timeout = 30;
              command = "${getExe pkgs.swaylock} -efF";
            }
          ]
          ++ (
            optionals osCfg.enable [
              {
                timeout = 20 * 60;
                command = "${getExe' pkgs.systemd "systemctl"} -i suspend";
              }
            ]
          );
      };
    };

    wayland.windowManager.hyprland.settings = {
      env = [
        # wl-roots
        "WLR_DRM_DEVICES,/dev/dri/card1:/dev/dri/card0"
        "WLR_RENDERER,vulkan"
        # XDG
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        # Toolkit
        "CLUTTER_BACKEND,wayland"
        "GDK_BACKEND,wayland"
        "QT_QPA_PLATFORM,wayland"
        "SDL_VIDEODRIVER,wayland"
        # Qt
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        # NVIDIA
        "LIBVA_DRIVER_NAME,nvidia"
        "__GL_GSYNC_ALLOWED,1"
        "__GL_VRR_ALLOWED,1"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];

      monitor = "DP-1,highrr,auto,auto,vrr,1,bitdepth,10";

      binds = {
        workspace_back_and_forth = true;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      general = {
        cursor_inactive_timeout = 60;
        allow_tearing = false;
      };

      master = {
        new_is_master = true;
      };

      misc = {
        force_default_wallpaper = "-1"; # Set to 0 to disable the anime mascot wallpapers
        focus_on_activate = true;
      };
    };
  }
