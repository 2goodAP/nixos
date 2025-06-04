{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ./applications.nix
    ./display.nix
    ./widgets.nix
  ];

  config = let
    cfg = config.tgap.home.desktop;
    hyCfg = config.wayland.windowManager.hyprland;
    osHyCfg = osConfig.programs.hyprland;
    osCfg = osConfig.tgap.system;
    inherit (lib) getExe getExe' mapAttrsToList mkIf optionals optionalAttrs;

    configTemplates =
      {
        "%XKB_LAYOUT%" = osConfig.services.xserver.xkb.layout;
        "%XKB_VARIANT%" = osConfig.services.xserver.xkb.variant;
        "%XKB_OPTIONS%" =
          builtins.replaceStrings
          ["grp:menu_toggle"] ["grp:ctrls_toggle"]
          osConfig.services.xserver.xkb.options;

        "%NIRI_TMP%" = "$XDG_RUNTIME_DIR/niri";
        "%SNKVOLPIPE%" = "snkvolpipe";
        "%SRCVOLPIPE%" = "srcvolpipe";

        "%EWW%" = getExe config.programs.eww.package;
        "%FUZZEL%" = getExe config.programs.fuzzel.package;
        "%HYPRLOCK%" = getExe config.programs.hyprlock.package;
        "%SWAPPY%" = getExe pkgs.swappy;
        "%WLOGOUT%" = getExe pkgs.wlogout;
        "%WLPASTE%" = getExe' pkgs.wl-clipboard "wl-paste";
        "%WPCTL%" = getExe' osConfig.services.pipewire.wireplumber.package "wpctl";
      }
      // optionalAttrs (cfg.terminal.name == "ghostty") {
        "%LAUNCH_TERMINAL%" = ''Mod+Return { spawn "${getExe
            config.programs.ghostty.package}"; }'';
        "%LAUNCH_CLIPSE%" = ''Mod+C { spawn "${
            getExe config.programs.ghostty.package
          }" "--class=org.clipse" "-e" "${getExe
            config.services.clipse.package}"; }'';
      }
      // optionalAttrs (cfg.terminal.name == "wezterm") {
        "%LAUNCH_TERMINAL%" = ''Mod+Return { spawn "${
            getExe config.programs.wezterm.package
          }" "start" "--cwd" "."; }'';
        "%LAUNCH_CLIPSE%" = ''Mod+C { spawn "${
            getExe config.programs.wezterm.package
          }" "start" "--cwd" "." "--class" "clipse" "--" "${getExe
            config.services.clipse.package}"; }'';
      };
  in
    mkIf (osCfg.desktop.enable && osCfg.desktop.manager == "niri") {
      home.activation.activateQtctConfig = let
        qt5ctConf = builtins.readFile ./qtct/qt5ct.conf;
        qt6ctConf = builtins.readFile ./qtct/qt6ct.conf;
        qt5ctConfFile = "${config.xdg.configHome}/qt5ct/qt5ct.conf";
        qt6ctConfFile = "${config.xdg.configHome}/qt6ct/qt6ct.conf";
      in
        lib.hm.dag.entryAfter ["linkGeneration"] ''
          # Ensure that qt5ct.conf and qt6ct.conf exist
          mkdir -p ${dirOf qt5ctConfFile}
          mkdir -p ${dirOf qt6ctConfFile}
          touch ${qt5ctConfFile}
          touch ${qt6ctConfFile}

          # Replace relevant parts of the configs
          # qt5ct
          ${getExe pkgs.gawk} -Oi inplace -v INPLACE_SUFFIX=.hm.bak \
            '/^\s*\[/ {found = 0} $0 ~ "${
            lib.concatStringsSep "|" (lib.flatten
              (lib.partition (e: lib.isList e)
                (builtins.split "[[]([[:alpha:]]+)[]]" qt5ctConf))
              .right)
          }" {found = 1; next} !found' ${qt5ctConfFile}
          cat >> ${qt5ctConfFile} << EOF
          ${builtins.replaceStrings ["@configDir@"]
            [(dirOf qt5ctConfFile)]
            qt5ctConf}
          EOF

          # qt6ct
          ${getExe pkgs.gawk} -Oi inplace -v INPLACE_SUFFIX=.hm.bak \
            '/^\s*\[/ {found = 0} $0 ~ "${
            lib.concatStringsSep "|" (lib.flatten
              (lib.partition (e: lib.isList e)
                (builtins.split "[[]([[:alpha:]]+)[]]" qt6ctConf))
              .right)
          }" {found = 1; next} !found' ${qt6ctConfFile}
          cat >> ${qt6ctConfFile} << EOF
          ${builtins.replaceStrings ["@configDir@"]
            [(dirOf qt6ctConfFile)]
            qt6ctConf}
          EOF
        '';

      gtk = {
        enable = true;

        iconTheme = {
          name = "Papirus";
          package = pkgs.papirus-icon-theme;
        };

        theme = {
          name = "Breeze";
          package = pkgs.kdePackages.breeze-gtk;
        };
      };

      home = {
        sessionVariables.QT_QUICK_CONTROLS_STYLE = "org.kde.breeze";

        packages = with pkgs; [
          bibata-cursors
          kdePackages.breeze
          kdePackages.breeze.qt5
          kdePackages.qqc2-breeze-style
          libsForQt5.qqc2-breeze-style
        ];

        pointerCursor = {
          gtk.enable = true;
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
          size = 24;
        };
      };

      programs.eww = let
        configDir = pkgs.runCommand "eww-config-dir" {} ''
          mkdir $out

          # eww.scss
          echo '${builtins.replaceStrings ["'"] ["'\"'\"'"]
            (builtins.readFile ./eww/eww.scss)}' > $out/eww.scss

          # eww.yuck
          echo '${builtins.replaceStrings
            (["'"] ++ (mapAttrsToList (name: _: name) configTemplates))
            (["'\"'\"'"] ++ (mapAttrsToList (_: value: value) configTemplates))
            (builtins.readFile ./eww/eww.yuck)}' > $out/eww.yuck
        '';
      in {
        enable = true;
        inherit configDir;
      };

      qt = {
        enable = true;
        platformTheme.name = "qtct";
      };

      wayland.windowManager.hyprland = let
        mod = "SUPER";
      in {
        enable = osHyCfg.enable;
        package = osHyCfg.package;
        portalPackage = osHyCfg.portalPackage;
        plugins = [];

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
            bezier = "easeOutExpo, 0.16, 1, 0.3, 1";
            animation = [
              "windows, 1, 7, easeOutExpo"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
          };

          bind = [
            "${mod}, return, exec, ${getExe cfg.terminal.package}"
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

          binds = {
            allow_workspace_cycles = true;
            pass_mouse_when_bound = true;
            workspace_back_and_forth = true;
          };

          decoration = {
            rounding = 10;
            dim_inactive = true;
            dim_strength = 0.15;
            shadow.enabled = true;
            blur = {
              enabled = true;
              xray = true;
              size = 3;
              passes = 1;
            };
          };

          device = {
            name = "compx-fantech-heliosgo-pro-wireless-xd5";
            accel_profile = "flat";
          };

          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };

          env = [
            # XDG
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_DESKTOP,Hyprland"
            "XDG_SESSION_TYPE,wayland"

            # Nvidia
            "GBM_BACKEND,nvidia"
            "LIBVA_DRIVER_NAME,nvidia"
            "NVD_BACKEND,direct"
            "__GL_GSYNC_ALLOWED,1"
            "__GL_VRR_ALLOWED,1"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"

            # Toolkit
            "CLUTTER_BACKEND,wayland"
            "ELECTRON_OZONE_PLATFORM_HINT,auto"
            "GDK_BACKEND,wayland"
            "QT_QPA_PLATFORM,wayland"
            #"SDL_VIDEODRIVER,wayland"

            # Java
            "_JAVA_AWT_WM_NONREPARENTING,1"

            # Qt
            "QT_AUTO_SCREEN_SCALE_FACTOR,1"
            "QT_QPA_PLATFORMTHEME,qt5ct"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"

            # Firefox
            "MOZ_ENABLE_WAYLAND,1"
          ];

          exec-once = [
            ("[silent] ${pkgs.libsForQt5.polkit-kde-agent}"
              + "/libexec/polkit-kde-authentication-agent-1")
            "[workspace 6 silent] ${getExe' pkgs.keepassxc "keepassxc"}"
            "[silent] ${getExe pkgs.nextcloud-client}"
            ("${getExe' hyCfg.package "hyprctl"} setcursor"
              + " ${config.home.pointerCursor.name} "
              + toString config.home.pointerCursor.size)
          ];

          general = {
            allow_tearing = false;
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
            kb_layout = osConfig.services.xserver.xkb.layout;
            kb_variant = osConfig.services.xserver.xkb.variant;
            kb_options = osConfig.services.xserver.xkb.options;
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
            "float, class:^(.*udiskie.*)$"
          ];
        };
      };

      xdg.configFile = {
        "qt5ct/style-colors.conf".source = ./qtct/qt5-style-colors.conf;
        "qt6ct/style-colors.conf".source = ./qtct/qt6-style-colors.conf;

        "niri/config.kdl".text =
          builtins.replaceStrings
          (mapAttrsToList (name: _: name) configTemplates)
          (mapAttrsToList (_: value: value) configTemplates)
          (builtins.readFile ./niri-config.kdl);
      };
    };
}
