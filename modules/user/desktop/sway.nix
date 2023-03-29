{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.user.desktop.sway = let
    inherit (lib) mkOption types;
  in {
    enable = mkOption {
      description = "Whether or not to enable swaywm and supporting programs.";
      type = types.bool;
      default = false;
    };

    extraConfigEarly = mkOption {
      description = "Extra configuration lines to add to ~/.config/sway/config before all other configuration.";
      type = types.lines;
      default = "";
    };

    extraConfig = mkOption {
      description = "Extra configuration lines to add to ~/.config/sway/config.";
      type = types.lines;
      default = "";
    };

    systemdTarget = mkOption {
      description = "Systemd target to bind to.";
      type = types.str;
      default = "sway-session.target";
    };
  };

  config = let
    cfg = config.tgap.user.desktop.sway;
    inherit (lib) mkIf;
    writeIf = cond: msg:
      if cond
      then msg
      else "";
  in
    mkIf cfg.enable {
      wayland.windowManager.sway = {
        enable = true;
        swaynag.enable = true;
        wrapperFeatures.gtk = true;
        extraOptions = ["--unsupported-gpu"];

        config = {
          input = {
            "*" = {
              xkb_layout = "us,np";
              xkb_variant = "altgr-intl,";
              accel_profile = "flat";
            };

            "1:1:AT_Translated_Set_2_keyboard" = {
              xkb_layout = "us,np";
              xkb_variant = "colemak_dh,";
            };

            "1267:12433:ELAN0504:01_04F3:3091_Touchpad" = {
              accel_profile = "adaptive";
              click_method = "clickfinger";
              dwt = "enabled";
              natural_scroll = "enabled";
              tap = "enabled";
            };
          };

          bindkeysToCode = true;

          floating = {
            border = 2;
            titlebar = false;

            criteria = [
              {appId = "com.nextcloud.desktopclient.nextcloud";}
              {
                appId = "firefox";
                title = "^$";
              }
              {appId = "wev";}
              {appId = "pavucontrol";}
              {
                appId = "org.keepassxc.KeePassXC";
                title = "Access\s*Request";
              }
            ];
          };

          focus = {
            followMouse = false;
            forceWrapping = true;
            mouseWarping = "output";
          };

          gaps = {
            inner = 5;
            smartGaps = true;
          };

          fonts = ["pango:sans serif 11" "pango:NotoSans Nerd Font 11"];

          colors = {
            focused = {
              border = "#77767b";
              background = "#deddda";
              text = "#000000";
              indicator = "#77767b";
              childBorder = "#77767b";
            };
            focusedInactive = {
              border = "#c0bfbc";
              background = "#ebebeb";
              text = "#5e5c64";
              indicator = "#c0bfbc";
              childBorder = "#c0bfbc";
            };
            unfocused = {
              border = "#deddda";
              background = "#fafafa";
              text = "#c0bfbc";
              indicator = "#deddda";
              childBorder = "#deddda";
            };
            urgent = {
              border = "#ae7b03";
              background = "#e5a50a";
              text = "#ffffff";
              indicator = "#ae7b03";
              childBorder = "#ae7b03";
            };
          };
        };

        inherit (cfg) extraConfigEarly extraConfig;

        extraSessionCommands = ''
          # Set wlroots renderer to Vulkan to avoid flickering.
          export WLR_RENDERER=vulkan
          export WLR_DRM_NO_MODIFIERS=1

          # General wayland environment variables.
          export XDG_SESSION_TYPE=wayland
          export CLUTTER_BACKEND=wayland
          export QT_QPA_PLATFORM=wayland
          export QT_WAYLAND_FORCE_DPI=physical
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          export ECORE_EVAS_ENGINE=wayland
          export ELM_ENGINE=wayland
          export _JAVA_AWT_WM_NONREPARENTING=1

          # Enable appindicator tray for waybar.
          export XDG_CURRENT_DESKTOP=Unity

          # Firefox wayland environment variable.
          export MOZ_ENABLE_WAYLAND=1
          export MOZ_USE_XINPUT2=1

          # OpenGL Variables.
          export GBM_BACKEND=nvidia-drm
          export __GL_GSYNC_ALLOWED=1
          export __GL_VRR_ALLOWED=1
          export __GLX_VENDOR_LIBRARY_NAME=nvidia
        '';
      };

      programs = {
        mako.enable = true;

        rofi = {
          enable = true;
          package = pkgs.rofi-wayland;
          cycle = true;
          font = "NotoSans Nerd Font 12";
          terminal = "\${pkgs.foot}/bin/foot";

          extraConfig = {
            modi = "drun,combi,ssh,filebrowser";
            show-icons = true;
            display-drun = " Apps";
            display-combi = " Combi";
            display-ssh = " SSH";
            display-filebrowser = " Files";
            drun-display-format = "{name}";
            window-format = "{w} · {c} · {t}";
          };

          theme = let
            inherit (lib.formats.rasi) mkLiteral;
          in {
            "*" = {
              border = mkLiteral "0";
              margin = mkLiteral "0";
              padding = mkLiteral "0";

              alt-bg-color = mkLiteral "#ebebeb";
              bg-color = mkLiteral "#fafafa";
              border-color = mkLiteral "rgba(24, 24, 24, 0.5)";
              alt-fg-color = mkLiteral "#ffffff";
              fg-color = mkLiteral "rgba(0, 0, 0, 0.8)";
              sh-fg-color = mkLiteral "rgba(0, 0, 0, 0.36)";
              sel-bg-color = mkLiteral "#3584e4";
              act-bg-color = mkLiteral "#2ec27e";
              urg-bg-color = mkLiteral "#e5a50a";

              border-rad = mkLiteral "5px";
              padding-l = mkLiteral "20px";
              padding-s = mkLiteral "10px";
              win-border = mkLiteral "2px solid";
            };

            # Main
            window = {
              background-color = mkLiteral "@bg-color";
              border = mkLiteral "@win-border";
              border-radius = mkLiteral "@border-rad";
              transparency = "real";
            };
            mainbox = {
              background-color = mkLiteral "transparent";
              spacing = mkLiteral "10px";
              padding = mkLiteral "@padding-l";
              children = ["inputbar" "bodybox"];
            };

            ## Inputbar
            inputbar = {
              background-color = mkLiteral "@alt-bg-color";
              border-radius = mkLiteral "@border-rad";
              children = [
                "textbox-prompt-colon"
                "entry"
                "num-filtered-rows"
                "textbox-num-sep"
                "num-rows"
              ];
              padding = mkLiteral "@padding-s";
              spacing = mkLiteral "inherit";
              text-color = mkLiteral "@fg-color";
            };
            textbox-prompt-colon = {
              str = "";
              text-color = mkLiteral "inherit";
            };
            entry = {
              cursor = mkLiteral "text";
              placeholder = "Search...";
              placeholder-color = mkLiteral "@sh-fg-color";
              text-color = mkLiteral "inherit";
            };
            num-filtered-rows = {text-color = mkLiteral "@sh-fg-color";};
            textbox-num-sep = {text-color = mkLiteral "@sh-fg-color";};
            num-rows = {text-color = mkLiteral "@sh-fg-color";};

            # Bodybox
            bodybox = {
              background-color = mkLiteral "inherit";
              children = ["mode-switcher" "listview"];
              orientation = mkLiteral "horizontal";
              spacing = mkLiteral "inherit";
              text-color = mkLiteral "@fg-color";
            };

            ## Mode Switcher
            mode-switcher = {
              background-color = mkLiteral "transparent";
              orientation = mkLiteral "vertical";
              spacing = mkLiteral "inherit";
              text-color = mkLiteral "@fg-color";
            };
            button = {
              border-radius = mkLiteral "@border-rad";
              background-color = mkLiteral "@alt-bg-color";
              cursor = mkLiteral "pointer";
              padding = mkLiteral "@padding-l";
              text-color = mkLiteral "inherit";
            };
            "button selected" = {
              background-color = mkLiteral "@sel-bg-color";
              text-color = mkLiteral "@alt-fg-color";
            };

            ## Listview
            listview = {
              background-color = mkLiteral "transparent";
              border = mkLiteral "inherit";
              cycle = true;
              dynamic = true;
              fixed-height = true;
              fixed-columns = true;
              lines = mkLiteral "10";
              orientation = mkLiteral "vertical";
              reverse = false;
              scrollbar = true;
              spacing = mkLiteral "inherit";
              text-color = mkLiteral "@fg-color";
            };
            scrollbar = {
              background-color = mkLiteral "@alt-bg-color";
              border-radius = mkLiteral "@border-rad";
              handle-width = mkLiteral "5px";
              handle-color = mkLiteral "@sel-bg-color";
            };
            element = {
              background-color = mkLiteral "transparent";
              border-radius = mkLiteral "@border-rad";
              cursor = mkLiteral "pointer";
              padding = mkLiteral "@padding-s";
              spacing = mkLiteral "inherit";
              text-color = mkLiteral "@fg-color";
            };
            element-icon = {
              background-color = mkLiteral "transparent";
              cursor = mkLiteral "inherit";
              size = mkLiteral "24px";
              text-color = mkLiteral "inherit";
            };
            element-text = {
              background-color = mkLiteral "transparent";
              cursor = mkLiteral "inherit";
              text-color = mkLiteral "inherit";
            };
            "element selected.normal" = {
              background-color = mkLiteral "@sel-bg-color";
              text-color = mkLiteral "@alt-fg-color";
            };
            "element selected.active" = {background-color = mkLiteral "@act-bg-color";};
            "element selected.urgent" = {background-color = mkLiteral "@urg-bg-color";};
            "element alternate.normal" = {background-color = mkLiteral "inherit";};
            "element alternate.active" = {background-color = mkLiteral "@act-bg-color";};
            "element alternate.urgent" = {background-color = mkLiteral "@urg-bg-color";};
            "element normal.normal" = {background-color = mkLiteral "inherit";};
            "element normal.active" = {background-color = mkLiteral "@act-bg-color";};
            "element normal.urgent" = {background-color = mkLiteral "@urg-bg-color";};

            ##  Message
            message = {
              background-color = mkLiteral "transparent";
              text-color = mkLiteral "@fg-color";
            };
            textbox = {
              border-radius = mkLiteral "@border-rad";
              background-color = mkLiteral "@alt-bg-color";
              padding = mkLiteral "@padding-s";
              placeholder-color = mkLiteral "@special-alt";
              text-color = mkLiteral "inherit";
            };

            ## Error Message
            error-message = {
              background-color = mkLiteral "@bg-color";
              padding = mkLiteral "@padding-l";
              text-color = mkLiteral "@fg-color";
            };
          };
        };

        waybar = {
          enable = true;
          systemd = {
            enable = true;
            target = cfg.systemdTarget;
          };

          settings = {
            mainBar = {
              layer = "bottom";
              position = "bottom";
              spacing = 3;

              modules-left = [
                "sway/workspaces"
                "sway/mode"
                "sway/window"
              ];
              modules-right = [
                "idle_inhibitor"
                "sway/language"
                "backlight"
                "pulseaudio"
                "battery"
                "bluetooth"
                "network"
                "clock"
                "tray"
              ];

              "sway/mode" = {
                format = "<span style=\"italic\">{}</span>";
              };

              "sway/window" = {
                format = "{title}";
                tooltip = false;
              };

              "sway/language" = {
                on-click = "swaymsg input type:keyboard xkb_switch_layout next";
                on-click-right = "swaymsg input type:keyboard xkb_switch_layout prev";
              };

              idle_inhibitor = {
                format = "{icon}";
                format-icons = {
                  activated = "";
                  deactivated = "";
                };
              };

              backlight = {
                format = "{icon} {percent}%";
                format-icons = ["" "" ""];
              };

              pulseaudio = {
                format = "{icon} {volume}% {format_source}";
                format-bluetooth = "{icon} {volume}% {format_source}";
                format-bluetooth-muted = "婢 {format_source}";
                format-muted = "婢 {format_source}";
                format-source = " {volume}%";
                format-source-muted = "";
                format-icons = {
                  headphone = "";
                  hands-free = "";
                  headset = "";
                  phone = "";
                  portable = "";
                  car = "";
                  default = ["奄" "奔" "墳"];
                };
                on-click = "pavucontrol";
              };

              battery = {
                states = {
                  warning = 30;
                  critical = 20;
                };
                format = "{icon} {capacity}%";
                format-icons = ["" "" "" "" ""];
                format-charging = " {capacity}%";
                format-full = " 100%";
              };

              bluetooth = {
                format-disabled = "";
                format-on = "";
                format-off = "";
                format-connected = "";
                tooltip-format = "{controller_address} {controller_alias}\n\n{num_connections} connected";
                tooltip-format-connected = "{controller_address} {controller_alias}\n\n{num_connections} connected\n\n{device_enumerate}";
                tooltip-format-enumerate-connected = "{device_address} {device_alias}";
                tooltip-format-enumerate-connected-battery = "{device_address} {device_alias} {device_battery_percentage}%";
              };

              network = {
                format-disabled = "";
                format-wifi = "直 {signalStrength}%";
                format-ethernet = "";
                tooltip-format-wifi = "{essid}: {bandwidthDownBits}, {bandwidthUpBits}";
                tooltip-format-ethernet = "{ipaddr}/{cidr}: {bandwidthDownBits}, {bandwidthUpBits}";
                format-linked = "";
                format-disconnected = "";
              };

              clock = {
                format = " {:%a, %b %d, %I:%M %p}";
                tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              };

              tray = {
                spacing = 5;
              };
            };
          };

          style = ''
            @define-color special_fg_color #ffffff;

            /* --------- *
             * Keyframes *
             * --------- */

            @keyframes blink-warning {
              70% { color: @special_fg_color; }

              to {
                background-color: @warning_color;
                color:            @special_fg_color;
              }
            }

            @keyframes blink-critical {
              70% { color: @special_fg_color}

              to {
                background-color: @error_color;
                color:            @special_fg_color;
              }
            }

            /* ----------- *
             * Base styles *
             * ----------- */

            /* Reset all styles. */
            * {
              border:           none;
              border-radius:    0.4rem;
              font-family:      NotoSans Nerd Font, sans-serif;
              font-size:        1.1rem;
              min-height:       0;
              margin:           0;
              padding:          0;
            }

            #waybar {
              background-color: @theme_base_color;
              color:            @theme_fg_color;
              border-top:       0.2rem solid @borders;
            }

            /* Adjust margins and padding for all modules. */
            .modules-left,
            .modules-center,
            .modules-right { margin-top: 0.25rem; }

            #tray,
            #clock,
            #network,
            #bluetooth,
            #battery,
            #pulseaudio,
            #backlight,
            #language,
            #idle_inhibitor {
              color:   inherit;
              padding: 0.4rem;
            }
            #workspaces button { padding: 0.4rem 0.2rem; }
            #mode, #window     { padding: 0.4rem; }

            /* ------------- *
             * Module styles *
             * ------------- */

            #mode {
              background-color: @theme_selected_bg_color;
              color:            @theme_selected_fg_color;
              border-bottom:    0.3rem;
            }

            #window { font-size: 1rem; }

            #battery {
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction:       alternate;
            }
            #battery.warning  { color: @warning_color; }
            #battery.critical { color: @error_color;   }
            #battery.warning.discharging {
              animation-name:     blink-warning;
              animation-duration: 3s;
            }
            #battery.critical.discharging {
              animation-name:     blink-critical;
              animation-duration: 2s;
            }

            #pulseaudio.muted { color: @theme_unfocused_fg_color; }

            #workspaces button { color: @theme_unfocused_fg_color; }
            #workspaces button.urgent {
              background-color: @warning_color;
              color:            @special_fg_color;
              border:           2px solid @warning_color;
            }
            #workspaces button.focused {
              background-color: @theme_bg_color;
              color:            @theme_fg_color;
              border:           2px solid @borders;
            }

            #idle_inhibitor.activated { color: @theme_selected_bg_color; }

            #tray > .passive { -gtk-icon-effect: dim; }
            #tray > .needs-attention {
              background-color: @warning_color;
              color:            @special_fg_color;
              -gtk-icon-effect: highlight;
            }
          '';
        };

        swaylock.settings = let
          blue = "1c71d8ff";
          green = "2ec27eff";
          red = "e01b24ff";
          yellow = "e5a50aff";
          primary = "fafafaff";
          secondary = "c0bfbcff";
          transparent = "24242400";
        in {
          daemonize = true;
          ignore-empty-password = true;
          scaling = "fill";
          indicator-radius = 80;
          indicator-thickness = 15;
          indicator-caps-lock = true;
          disable-caps-lock-text = true;
          key-hl-color = green;
          bs-hl-color = red;
          separator-color = primary;
          inside-color = transparent;
          inside-clear-color = transparent;
          inside-caps-lock-color = transparent;
          inside-ver-color = transparent;
          inside-wrong-color = transparent;
          line-color = primary;
          line-clear-color = primary;
          line-caps-lock-color = primary;
          line-ver-color = primary;
          line-wrong-color = primary;
          ring-color = primary;
          ring-clear-color = secondary;
          ring-caps-lock-color = yellow;
          ring-ver-color = blue;
          ring-wrong-color = red;
          text-color = primary;
          text-clear-color = transparent;
          text-caps-lock-color = primary;
          text-ver-color = transparent;
          text-wrong-color = transparent;
        };
      };

      services = {
        clipman = {
          enable = true;
          inherit (cfg) systemdTarget;
        };

        # Display
        gammastep = {
          enable = true;
          tray = true;
          latitude = 0.0;
          longitude = 0.0;
          temperature.day = 2300;
          temperature.night = 2300;
          settings.general.adjustment-method = "wayland";
        };

        kanshi.enable = true;

        # Locking
        swayidle = {
          enable = true;
          extraArgs = ["-w"];
          inherit (cfg) systemdTarget;

          events = [
            {
              event = "before-sleep";
              command = "${pkgs.swaylock}/bin/swaylock";
            }
          ];
          timeouts = [
            {
              timeout = 480;
              command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
              resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
            }
            {
              timeout = 600;
              command = "${pkgs.swaylock}/bin/swaylock";
            }
            {
              timeout = 720;
              command = "${pkgs.systemd}/bin/systemctl -i suspend";
            }
          ];
        };
      };

      systemd.user = {
        services.wob = {
          enable = true;
          Unit = {
            Description = "A lightweight overlay volume/backlight/progress/anything bar for Wayland";
            Documentation = "man:wob(1)";
            PartOf = [cfg.systemdTarget];
            After = [cfg.systemdTarget];
            ConditionEnvironment = "WAYLAND_DISPLAY";
          };
          Service = {
            StandardInput = "socket";
            ExecStart = "${pkgs.wob}/bin/wob";
          };
          Install = {
            WantedBy = [cfg.systemdTarget];
          };
        };

        sockets.wob = {
          enable = true;
          Socket = {
            ListenFIFO = "%t/wob.sock";
            SocketMode = 0600;
            RemoveOnStop = true;
            FlushPending = true;
          };
          Install = {
            WantedBy = [cfg.systemdTarget];
          };
        };
      };

      home.packages = let
        # A Bash script to let dbus know about important env variables and
        # propogate them to relevent services run at the end of sway config.
        dbus-sway-environment = pkgs.writeTextFile rec {
          name = "dbus-sway-environment";
          destination = "/bin/${name}";
          executable = true;

          text = ''
            dbus-update-activation-environment --systemd WAYLAND_DISPLAY \
              XDG_CURRENT_DESKTOP=sway
            systemctl --user restart pipewire wireplumber xdg-desktop-portal \
              xdg-desktop-portal-wlr
          '';
        };
      in
        [
          # Screensharing
          dbus-sway-environment
        ]
        ++ (with pkgs; [
          # Bar
          libappindicator-gtk3
          # Deps
          vulkan-validation-layers
          # Desktop
          swaybg
          # Input
          wev
          wl-clipboard
          ydotool
          # Locking
          swaylock
          # Screenshot
          sway-contrib.grimshot
          # Terminal
          foot
          # Volume
          pavucontrol
        ]);
    };
}
