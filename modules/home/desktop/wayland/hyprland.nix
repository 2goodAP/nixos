{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop.wayland;
  osCfg = osConfig.tgap.system;
  inherit (lib) getExe getExe' mkIf optionals;
in
  mkIf (
    osCfg.desktop.enable
    && osCfg.desktop.manager == "wayland"
    && cfg.windowManager == "hyprland"
  ) {
    tgap.home.desktop.wayland.systemdTarget = "hyprland-session.target";

    wayland.windowManager.hyprland = let
      hyprland = inputs.hyprland.packages."${pkgs.system}".hyprland;
      mod = "SUPER";
    in {
      enable = true;
      package = hyprland;
      plugins = [inputs.hy3.packages."${pkgs.system}".hy3];

      extraConfig = ''
        # window resize
        bind = ${mod}, r, submap, resize

        submap = resize
        binde = , h, resizeactive, -10 0
        binde = , j, resizeactive, 0 10
        binde = , k, resizeactive, 0 -10
        binde = , l, resizeactive, 10 0
        bind = , escape, submap, reset
        submap = reset
      '';

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
          "${mod}, return, exec, ${getExe pkgs.kitty}"
          "${mod} SHIFT, q, killactive,"
          "${mod} SHIFT, e, exec, ${getExe pkgs.wlogout}"
          "${mod}, space, togglefloating,"
          ("${mod}, c, exec, exec ${getExe pkgs.cliphist} list"
            + " | ${getExe' pkgs.rofi-wayland "rofi"} -dmenu"
            + " | ${getExe pkgs.cliphist} decode"
            + " | ${getExe' pkgs.wl-clipboard "wl-copy"}")
          ("${mod}, d, exec, ${getExe' pkgs.rofi-wayland "rofi"}"
            + " -show combi -modes combi -combi-modes window,drun,run")
          "${mod}, p, pseudo," # dwindle
          "${mod}, m, togglesplit," # dwindle
          "${mod}, x, exec, ${getExe' pkgs.systemd "loginctl"} lock-session"
          "${mod}, tab, workspace, previous"

          # Move focus with super + arrow keys
          "${mod}, h, movefocus, l"
          "${mod}, j, movefocus, d"
          "${mod}, k, movefocus, u"
          "${mod}, l, movefocus, r"

          "${mod} SHIFT, h, movewindow, l"
          "${mod} SHIFT, j, movewindow, d"
          "${mod} SHIFT, k, movewindow, u"
          "${mod} SHIFT, l, movewindow, r"

          "${mod} ALT, h, swapwindow, l"
          "${mod} ALT, j, swapwindow, d"
          "${mod} ALT, k, swapwindow, u"
          "${mod} ALT, l, swapwindow, r"

          # Switch workspaces with super + [0-9]
          "${mod}, 1, workspace, 1"
          "${mod}, 2, workspace, 2"
          "${mod}, 3, workspace, 3"
          "${mod}, 4, workspace, 4"
          "${mod}, 5, workspace, 5"
          "${mod}, 6, workspace, 6"
          "${mod}, 7, workspace, 7"
          "${mod}, 8, workspace, 8"
          "${mod}, 9, workspace, 9"
          "${mod}, 0, workspace, 10"
          "${mod}, minus, togglespecialworkspace,"

          # Move active window to a workspace with super + SHIFT + [0-9]
          "${mod} SHIFT, 1, movetoworkspace, 1"
          "${mod} SHIFT, 2, movetoworkspace, 2"
          "${mod} SHIFT, 3, movetoworkspace, 3"
          "${mod} SHIFT, 4, movetoworkspace, 4"
          "${mod} SHIFT, 5, movetoworkspace, 5"
          "${mod} SHIFT, 6, movetoworkspace, 6"
          "${mod} SHIFT, 7, movetoworkspace, 7"
          "${mod} SHIFT, 8, movetoworkspace, 8"
          "${mod} SHIFT, 9, movetoworkspace, 9"
          "${mod} SHIFT, 0, movetoworkspace, 10"
          "${mod} SHIFT, minus, movetoworkspacesilent, special"

          # Scroll through existing workspaces with super + scroll
          "${mod} CTRL, l, workspace, m+1"
          "${mod} CTRL, h, workspace, m-1"
          "${mod}, mouse_down, workspace, m+1"
          "${mod}, mouse_up, workspace, m-1"

          (", XF86AudioMicMute, exec, ${getExe' pkgs.wireplumber "wpctl"}"
            + " set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
          ", XF86Search, exec, ${getExe' pkgs.rofi-wayland "rofi"} -show run"
        ];

        bindel =
          [
            (", XF86AudioLowerVolume, exec, ${getExe' pkgs.wireplumber "wpctl"}"
              + " set-volume @DEFAULT_AUDIO_SINK@ 5%-")
            (", XF86AudioRaiseVolume, exec, ${getExe' pkgs.wireplumber "wpctl"}"
              + " set-volume @DEFAULT_AUDIO_SINK@ 5%+")
          ]
          ++ (optionals osCfg.laptop.enable [
            ", XF86MonBrightnessUp, exec, ${getExe pkgs.light} -A 2"
            ", XF86MonBrightnessDown, exec, ${getExe pkgs.light} -U 2"
          ]);

        bindl = [
          (", XF86AudioMute, exec, ${getExe' pkgs.wireplumber "wpctl"}"
            + " set-mute @DEFAULT_AUDIO_SINK@ toggle")
          ", XF86AudioPlay, exec, ${getExe pkgs.playerctl} play-pause"
          ", XF86AudioNext, exec, ${getExe pkgs.playerctl} next"
          ", XF86AudioPrev, exec, ${getExe pkgs.playerctl} previous"
        ];

        # Move/resize windows with super + LMB/RMB and dragging
        bindm = [
          "${mod}, mouse:272, movewindow"
          "${mod}, mouse:273, resizewindow"
        ];

        decoration = {
          rounding = 10;
          dim_inactive = true;
          dim_strength = 0.15;
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
          "WLR_NO_HARDWARE_CURSORS,1"
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
          "QT_QPA_PLATFORMTHEME,qt5ct"
          # Firefox
          "MOZ_ENABLE_WAYLAND,1"
          # Cursor
          ("XCURSOR_SIZE," + builtins.toString config.home.pointerCursor.size)
        ];

        exec-once = [
          ("[silent] ${pkgs.libsForQt5.polkit-kde-agent}"
            + "/libexec/polkit-kde-authentication-agent-1")
          "[workspace 6 silent] ${getExe' pkgs.keepassxc "keepassxc"}"
          "[silent] ${getExe pkgs.nextcloud-client}"
          ("${getExe' hyprland "hyprctl"} setcursor"
            + " ${config.home.pointerCursor.name} "
            + builtins.toString config.home.pointerCursor.size)
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
          kb_layout = osConfig.services.xserver.layout;
          kb_variant = osConfig.services.xserver.xkbVariant;
          kb_options = osConfig.services.xserver.xkbOptions;
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
          key_press_enables_dpms = true;
          mouse_move_enables_dpms = true;
        };

        monitor =
          "desc:Microstep MSI G273Q CA8A462800094,"
          + " 2560x1440@165Hz, auto, auto, vrr, 1";

        windowrulev2 = [
          "float, class:^(.*blueman-manager.*)$"
          ("float, class:^(.*[Kk]ee[Pp]ass(XC|xc).*)$,"
            + " title:^(.*[Aa]ccess\\s*[Rr]equest.*)$")
          "float, class:^(.*nextcloud.*)$"
          "float, class:^(.*pavucontrol.*)$"
          "float, class:^(.*polkit-kde-authentication-agent.*)$"
          "float, class:^(.*soffice.*)$, title:^([Oo]pen.*)$"
        ];
      };
    };
  }
