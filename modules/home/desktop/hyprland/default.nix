{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
  ];

  options.tgap.home.desktop.hyprland = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Whether or not to enable hyprland and related-packages.";
  };

  config = let
    cfg = config.tgap.home.desktop.hyprland;
    inherit (lib) getExe getExe' mkIf;
  in
    mkIf cfg.enable {
      programs = {
        swaylock.enable = true;
        wlogout.enable = true;

        eww = {
          enable = true;
          package = pkgs.eww-wayland;
          configDir = ./bar;
        };
        rofi = {
          enable = true;
          package = pkgs.rofi-wayland.override {
            plugins = [pkgs.rofimoji];
          };
        };
      };

      services = {
        blueman-applet.enable = true;
        mako.enable = true;
        network-manager-applet.enable = true;
        playerctld.enable = true;
        swayosd.enable = true;

        cliphist = {
          enable = true;
          systemdTarget = "hyprland-session.target.";
        };
        kanshi = {
          enable = true;
          systemdTarget = "hyprland-session.target.";
        };
        swayidle = {
          enable = true;
          systemdTarget = "hyprland-session.target.";
        };
      };

      wayland.windowManager = {
        hyprland = {
          enable = true;
          package = inputs.hyprland.packages."${pkgs.system}".hyprland;

          settings = {
            monitor = ",highrr,auto,auto,vrr,1";

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

            input = {
              kb_layout = "us,us,np";
              kb_variant = "altgr-intl,colemak_dh,";
              kb_options = "grp:alt_caps_toggle";
              follow_mouse = 1;
              sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
              touchpad = {
                natural_scroll = "yes";
              };
            };

            general = {
              gaps_in = 5;
              gaps_out = 20;
              border_size = 2;
              "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
              "col.inactive_border" = "rgba(595959aa)";
              layout = "dwindle";
              allow_tearing = false;
            };

            decoration = {
              rounding = 10;
              drop_shadow = "yes";
              shadow_range = 4;
              shadow_render_power = 3;
              "col.shadow" = "rgba(1a1a1aee)";
              blur = {
                enabled = true;
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

            dwindle = {
              pseudotile = "yes";
              preserve_split = "yes";
            };

            master = {
              new_is_master = true;
            };

            gestures = {
              workspace_swipe = "off";
            };

            misc = {
              force_default_wallpaper = "-1"; # Set to 0 to disable the anime mascot wallpapers
            };

            "device:epic-mouse-v1" = {
              sensitivity = -0.5;
            };

            "$super" = "SUPER";
            bind = [
              "$super, Q, exec, ${getExe pkgs.kitty}"
              "$super, C, killactive,"
              "$super, M, exit,"
              "$super, V, togglefloating,"
              ''$super, R, exec, ${getExe' pkgs.rofi-wayland "rofi"} -show combi \
                  -modes combi -combi-modes window,drun,run''
              "$super, P, pseudo," # dwindle
              "$super, J, togglesplit," # dwindle

              # Move focus with super + arrow keys
              "$super, left, movefocus, l"
              "$super, right, movefocus, r"
              "$super, up, movefocus, u"
              "$super, down, movefocus, d"

              # Switch workspaces with super + [0-9]
              "$super, 1, workspace, 1"
              "$super, 2, workspace, 2"
              "$super, 3, workspace, 3"
              "$super, 4, workspace, 4"
              "$super, 5, workspace, 5"
              "$super, 6, workspace, 6"
              "$super, 7, workspace, 7"
              "$super, 8, workspace, 8"
              "$super, 9, workspace, 9"
              "$super, 0, workspace, 10"

              # Move active window to a workspace with super + SHIFT + [0-9]
              "$super SHIFT, 1, movetoworkspace, 1"
              "$super SHIFT, 2, movetoworkspace, 2"
              "$super SHIFT, 3, movetoworkspace, 3"
              "$super SHIFT, 4, movetoworkspace, 4"
              "$super SHIFT, 5, movetoworkspace, 5"
              "$super SHIFT, 6, movetoworkspace, 6"
              "$super SHIFT, 7, movetoworkspace, 7"
              "$super SHIFT, 8, movetoworkspace, 8"
              "$super SHIFT, 9, movetoworkspace, 9"
              "$super SHIFT, 0, movetoworkspace, 10"

              # Scroll through existing workspaces with super + scroll
              "$super, mouse_down, workspace, e+1"
              "$super, mouse_up, workspace, e-1"
            ];

            # Move/resize windows with super + LMB/RMB and dragging
            bindm = [
              "$super, mouse:272, movewindow"
              "$super, mouse:273, resizewindow"
            ];
          };
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

      home.packages = with pkgs; [
        hyprkeys
        hyprland-per-window-layout
        hyprpaper
        hyprpicker
        libnotify
        wallust
        watershot
        wev
        wlr-randr
        xdg-desktop-portal-hyprland
      ];
    };
}
