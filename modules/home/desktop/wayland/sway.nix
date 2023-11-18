{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop.wayland;
  osCfg = osConfig.tgap.system;
  sovSock = "$XDG_RUNTIME_DIR/sov.sock";
  inherit (lib) getExe getExe' mkIf mkOptionDefault optionalAttrs;
in
  mkIf (osCfg.desktop.enable && osCfg.desktop.manager == "wayland" && cfg.windowManager == "sway") {
    tgap.home.desktop.wayland.systemdTarget = "sway-session.target";

    wayland.windowManager.sway = {
      enable = true;
      extraOptions = ["--unsupported-gpu"];
      swaynag.enable = true;
      systemd.xdgAutostart = true;
      wrapperFeatures.gtk = true;

      config = {
        assigns."5" = [{app_id = "org.keepassxc.KeePassXC";}];
        bindkeysToCode = true;
        modifier = "Mod4";
        workspaceLayout = "tabbed";

        floating = {
          border = 4;
          titlebar = false;
        };

        focus = {
          followMouse = false;
          newWindow = "smart";
          wrapping = "force";
        };

        gaps = {
          inner = 10;
          smartGaps = true;
        };

        input = {
          "type:pointer".accel_profile = "flat";

          "type:keyboard" = (
            if osCfg.laptop.enable
            then {
              xkb_layout = "us,us,np";
              xkb_variant = "altgr-intl,colemak_dh,";
            }
            else {
              xkb_layout = "us,np";
              xkb_variant = "altgr-intl,";
            }
          );

          "type:touchpad" = {
            accel_profile = "adaptive";
            click_method = "clickfinger";
            drag = "enabled";
            drag_lock = "enabled";
            dwt = "enabled";
            middle_emulation = "enabled";
            natural_scroll = "enabled";
            tap = "enabled";
            tap_button_map = "lrm";
          };
        };

        keybindings = let
          mod = config.wayland.windowManager.sway.config.modifier;
        in
          mkOptionDefault (
            {
              "${mod}+d" = "exec '${getExe' pkgs.rofi-wayland "rofi"} -show combi -modes combi -combi-modes window,drun,run'";
              "${mod}+x" = "exec ${getExe pkgs.swaylock} -efF";
              "${mod}+Shift+a" = "focus child";
              "${mod}+Shift+e" = "exec ${getExe pkgs.wlogout}";
              "${mod}+Tab" = "workspace back_and_forth";

              "--no-repeat ${mod}+grave" = "exec 'echo 1 > ${sovSock}'";
              "--release ${mod}+grave" = "exec 'echo 0 > ${sovSock}'";
              "--locked ${mod}+Shift+n" = "input type:keyboard xkb_switch_layout next";
              "--locked ${mod}+Shift+p" = "input type:keyboard xkb_switch_layout prev";

              "--locked XF86AudioLowerVolume" = "exec ${getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
              "--locked XF86AudioRaiseVolume" = "exec ${getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 5%+";
              "--locked XF86AudioMute" = "exec ${getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SINK@ toggle";
              "--locked XF86AudioPlay" = "exec ${getExe pkgs.playerctl} play-pause";
              "--locked XF86AudioNext" = "exec ${getExe pkgs.playerctl} next";
              "--locked XF86AudioPrev" = "exec ${getExe pkgs.playerctl} previous";
              "XF86AudioMicMute" = "exec ${getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
              "XF86Search" = "exec ${getExe' pkgs.rofi-wayland "rofi"} -show run";
            }
            // (optionalAttrs osCfg.laptop.enable {
              "--locked XF86MonBrightnessUp" = "exec ${getExe pkgs.light} -A 2";
              "--locked XF86MonBrightnessDown" = "exec ${getExe pkgs.light} -U 2";
            })
          );

        output = {
          "Microstep MSI G273Q CA8A462800094" = {
            mode = "2560x1440@165Hz";
            adaptive_sync = "enabled";
          };
        };

        startup = [
          {command = "${getExe' pkgs.keepassxc "keepassxc"}";}
          {
            command = ''
              ${getExe' pkgs.coreutils "rm"} -f ${sovSock} \
                && ${getExe' pkgs.coreutils "mkfifo"} ${sovSock} \
                && ${getExe' pkgs.coreutils "tail"} -f ${sovSock} | ${getExe pkgs.sov}
            '';
          }
        ];

        window = {
          border = 4;
          titlebar = false;
        };
      };

      extraConfig = ''
        default_orientation auto
        hide_edge_borders smart_no_gaps
      '';

      extraSessionCommands = ''
        # wlroots
        export WLR_RENDERER=vulkan
        # XDG
        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_DESKTOP=sway
        export XDG_SESSION_TYPE=wayland
        # NVIDIA
        export GBM_BACKEND=nvidia
        export LIBVA_DRIVER_NAME=nvidia
        export __GL_GSYNC_ALLOWED=1
        export __GL_VRR_ALLOWED=1
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        # Toolkit
        export CLUTTER_BACKEND=wayland
        export GDK_BACKEND=wayland
        export QT_QPA_PLATFORM=wayland
        export SDL_VIDEODRIVER=wayland
        # Java
        _JAVA_AWT_WM_NONREPARENTING=1
        # SDL
        export SDL_DYNAMIC_API=${pkgs.SDL2}/lib/libSDL2.so
        # Qt
        export QT_AUTO_SCREEN_SCALE_FACTOR=1
        export QT_QPA_PLATFORMTHEME=qt5ct
        export QT_WAYLAND_FORCE_DPI=physical
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        # Firefox
        export MOZ_ENABLE_WAYLAND=1
      '';
    };
  }
