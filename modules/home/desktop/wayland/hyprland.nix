{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop.wayland;
  osCfg = osConfig.tgap.system.desktop;
  inherit (lib) getExe getExe' mkIf;
in
  mkIf (osCfg.enable && osCfg.manager == "wayland" && cfg.windowManager == "hyprland") {
    tgap.home.desktop.wayland.systemdTarget = "hyprland-session.target";

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      plugins = [inputs.hy3.packages."${pkgs.system}".hy3];

      settings = {
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

        bind = [
          "SUPER, return, exec, ${getExe pkgs.kitty}"
          "SUPER SHIFT, q, killactive,"
          "SUPER SHIFT, e, exec, ${getExe pkgs.wlogout}"
          "SUPER, space, togglefloating,"
          "SUPER, r, exec, ${getExe' pkgs.rofi-wayland "rofi"} -show combi -modes combi -combi-modes window,drun,run"
          "SUPER, p, pseudo," # dwindle
          "SUPER, m, togglesplit," # dwindle
          "SUPER, x, exec, ${getExe pkgs.swaylock} -edfF"

          # Move focus with super + arrow keys
          "SUPER, h, movefocus, l"
          "SUPER, l, movefocus, r"
          "SUPER, k, movefocus, u"
          "SUPER, j, movefocus, d"

          # Switch workspaces with super + [0-9]
          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 5"
          "SUPER, 6, workspace, 6"
          "SUPER, 7, workspace, 7"
          "SUPER, 8, workspace, 8"
          "SUPER, 9, workspace, 9"
          "SUPER, 0, workspace, 10"

          # Move active window to a workspace with super + SHIFT + [0-9]
          "SUPER SHIFT, 1, movetoworkspace, 1"
          "SUPER SHIFT, 2, movetoworkspace, 2"
          "SUPER SHIFT, 3, movetoworkspace, 3"
          "SUPER SHIFT, 4, movetoworkspace, 4"
          "SUPER SHIFT, 5, movetoworkspace, 5"
          "SUPER SHIFT, 6, movetoworkspace, 6"
          "SUPER SHIFT, 7, movetoworkspace, 7"
          "SUPER SHIFT, 8, movetoworkspace, 8"
          "SUPER SHIFT, 9, movetoworkspace, 9"
          "SUPER SHIFT, 0, movetoworkspace, 10"

          # Scroll through existing workspaces with super + scroll
          "SUPER ALT, l, workspace, e+1"
          "SUPER ALT, h, workspace, e-1"
        ];

        # Move/resize windows with super + LMB/RMB and dragging
        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];

        binds = {
          workspace_back_and_forth = true;
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

        device = {
          compx-fantech-heliosgo-pro-wireless-xd5 = {
            accel_profile = "flat";
          };
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        env = [
          # wl-roots
          "WLR_RENDERER,vulkan"
          # XDG
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          # NVIDIA
          "GBM_BACKEND,nvidia"
          "LIBVA_DRIVER_NAME,nvidia"
          "__GL_GSYNC_ALLOWED,1"
          "__GL_VRR_ALLOWED,1"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          # Toolkit
          "CLUTTER_BACKEND,wayland"
          "GDK_BACKEND,wayland"
          "QT_QPA_PLATFORM,wayland"
          #"SDL_VIDEODRIVER,wayland"
          # Java
          "_JAVA_AWT_WM_NONREPARENTING,1"
          # Qt
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          # Firefox
          "MOZ_ENABLE_WAYLAND,1"
        ];

        general = {
          allow_tearing = false;
          cursor_inactive_timeout = 60;
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
          resize_on_border = true;
        };

        gestures = {
          workspace_swipe = true;
        };

        input = {
          kb_layout = "us,us,np";
          kb_variant = "altgr-intl,colemak_dh,";
          kb_options = "grp:alt_caps_toggle";
          follow_mouse = 2;
          float_switch_override_focus = 0;

          accel_profile = "adaptive";
          sensitivity = 0;
          scroll_method = "2fg";
          touchpad = {
            natural_scroll = true;
            middle_button_emulation = true;
            clickfinger_behavior = true;
            drag_lock = true;
          };
        };

        master = {
          new_is_master = true;
        };

        misc = {
          force_default_wallpaper = "-1"; # Set to 0 to disable the anime mascot wallpapers
          focus_on_activate = true;
        };

        monitor = "DP-1,highrr,auto,auto,vrr,1,bitdepth,10";
      };
    };
  }
