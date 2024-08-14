{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop.wayland;
  osCfg = osConfig.tgap.system.desktop;
  inherit (lib) getExe mkIf mkMerge optionals;
in
  mkIf (osCfg.enable && osCfg.manager == "wayland") (mkMerge [
    {
      home.packages = [pkgs.libnotify];

      programs.waybar = {
        enable = true;

        settings = {
          main = {
            height = 30;
            layer = "top";
            position = "top";
            spacing = 4;

            modules-left =
              ["${cfg.windowManager}/workspaces"]
              ++ optionals (cfg.windowManager == "sway") ["${cfg.windowManager}/mode"];
            modules-center = ["${cfg.windowManager}/window"];
            modules-right = [
              "idle_inhibitor"
              "pulseaudio"
              "cpu"
              "memory"
              "temperature"
              "backlight"
              "keyboard-state"
              "${cfg.windowManager}/language"
              "battery"
              "clock"
              "privacy"
              "tray"
            ];
            "sway/mode" = {
              format = "<span style=\"italic\">{}</span>";
            };
            keyboard-state = {
              numlock = true;
              capslock = true;
              format = "{name} {icon}";
              format-icons = {
                locked = "";
                unlocked = "";
              };
            };
            idle_inhibitor = {
              format = "{icon}";
              format-icons = {
                activated = "";
                deactivated = "";
              };
            };
            tray = {
              spacing = 10;
            };
            clock = {
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              format-alt = "{:%Y-%m-%d}";
            };
            cpu = {
              format = "{usage}% ";
              tooltip = false;
            };
            memory = {
              format = "{}% ";
            };
            temperature = {
              thermal-zone = 2;
              hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
              critical-threshold = 80;
              format-critical = "{temperatureC}°C {icon}";
              format = "{temperatureC}°C {icon}";
              format-icons = ["" "" ""];
            };
            backlight = {
              format = "{percent}% {icon}";
              format-icons = ["" "" "" "" "" "" "" "" ""];
            };
            battery = {
              states = {
                good = 90;
                warning = 30;
                critical = 20;
              };
              format = "{capacity}% {icon}";
              format-charging = "{capacity}% ";
              format-plugged = "{capacity}% ";
              format-alt = "{time} {icon}";
              format-good = "";
              format-icons = ["" "" "" "" ""];
            };
            pulseaudio = {
              format = "{volume}% {icon} {format_source}";
              format-bluetooth = "{volume}% {icon} {format_source}";
              format-bluetooth-muted = " {icon} {format_source}";
              format-muted = " {format_source}";
              format-source = "{volume}% ";
              format-source-muted = "";
              format-icons = {
                headphone = "";
                hands-free = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = ["" "" ""];
              };
              on-click = "${getExe pkgs.pavucontrol}";
            };

            style = ''
              * {
                font-family: NotoSans Nerd Font, FontAwesome, sans-serif;
                font-size: 13px;
              }
              @keyframes blink {
                to {
                  background-color: #ffffff;
                  color: #000000;
                }
              }

              window#waybar {
                background-color: rgba(43, 48, 59, 0.5);
                border-bottom: 3px solid rgba(100, 114, 125, 0.5);
                color: #ffffff;
                transition-property: background-color;
                transition-duration: .5s;
              }
              window#waybar.hidden {
                opacity: 0.2;
              }
              window#waybar.empty {
                background-color: transparent;
              }
              window#waybar.solo {
                background-color: #FFFFFF;
              }

              button {
                box-shadow: inset 0 -3px transparent;
                border: none;
                border-radius: 0;
              }
              button:hover {
                background: inherit;
                box-shadow: inset 0 -3px #ffffff;
              }

              label:focus {
                background-color: #000000;
              }

              #workspaces button {
                padding: 0 5px;
                background-color: transparent;
                color: #ffffff;
              }
              #workspaces button:hover {
                background: rgba(0, 0, 0, 0.2);
              }
              #workspaces button.focused {
                background-color: #64727D;
                box-shadow: inset 0 -3px #ffffff;
              }
              #workspaces button.urgent {
                background-color: #eb4d4b;
              }

              #mode,
              #submap {
                background-color: #64727D;
                border-bottom: 3px solid #ffffff;
              }

              #battery,
              #backlight,
              #clock,
              #cpu,
              #disk,
              #idle_inhibitor,
              #language,
              #memory,
              #mode,
              #pulseaudio,
              #submap,
              #temperature,
              #tray,
              #wireplumber {
                padding: 0 10px;
                color: #ffffff;
              }

              #window,
              #workspaces {
                margin: 0 4px;
              }

              .modules-left > widget:first-child > #workspaces {
                margin-left: 0;
              }
              .modules-right > widget:last-child > #workspaces {
                margin-right: 0;
              }

              #clock {
                background-color: #64727D;
              }

              #battery {
                background-color: #ffffff;
                color: #000000;
              }
              #battery.charging, #battery.plugged {
                color: #ffffff;
                background-color: #26A65B;
              }
              #battery.critical:not(.charging) {
                background-color: #f53c3c;
                color: #ffffff;
                animation-name: blink;
                animation-duration: 0.5s;
                animation-timing-function: linear;
                animation-iteration-count: infinite;
                animation-direction: alternate;
              }

              #cpu {
                background-color: #2ecc71;
                color: #000000;
              }

              #memory {
                background-color: #9b59b6;
              }

              #disk {
                background-color: #964B00;
              }

              #backlight {
                background-color: #90b1b1;
              }

              #pulseaudio {
                background-color: #f1c40f;
                color: #000000;
              }
              #pulseaudio.muted {
                background-color: #90b1b1;
                color: #2a5c45;
              }

              #wireplumber {
                background-color: #fff0f5;
                color: #000000;
              }
              #wireplumber.muted {
                background-color: #f53c3c;
              }

              #temperature {
                background-color: #f0932b;
              }
              #temperature.critical {
                background-color: #eb4d4b;
              }

              #tray {
                background-color: #2980b9;
              }
              #tray > .passive {
                -gtk-icon-effect: dim;
              }
              #tray > .needs-attention {
                -gtk-icon-effect: highlight;
                background-color: #eb4d4b;
              }

              #idle_inhibitor {
                background-color: #2d3436;
              }
              #idle_inhibitor.activated {
                background-color: #ecf0f1;
                color: #2d3436;
              }

              #language {
                background: #00b093;
                color: #740864;
                padding: 0 5px;
                margin: 0 5px;
                min-width: 16px;
              }

              #keyboard-state {
                background: #97e1ad;
                color: #000000;
                padding: 0 0px;
                margin: 0 5px;
                min-width: 16px;
              }
              #keyboard-state > label {
                padding: 0 5px;
              }
              #keyboard-state > label.locked {
                background: rgba(0, 0, 0, 0.2);
              }

              #privacy {
                padding: 0;
              }
              #privacy-item {
                padding: 0 5px;
                color: white;
              }
              #privacy-item.screenshare {
                background-color: #cf5700;
              }
              #privacy-item.audio-in {
                background-color: #1ca000;
              }
              #privacy-item.audio-out {
                background-color: #0069d4;
              }
            '';
          };
        };

        systemd = {
          enable = true;
          target = cfg.systemdTarget;
        };
      };

      services = {
        blueman-applet.enable = true;
        network-manager-applet.enable = true;
        swayosd.enable = true;

        mako = {
          enable = true;
          borderRadius = 10;
          defaultTimeout = 10000;
          sort = "-priority";
        };
      };
    }

    (mkIf (cfg.windowManager == "sway") {
      systemd.user = {
        services.sov = {
          Install.WantedBy = [cfg.systemdTarget];

          Service = {
            Environment = "PATH=${pkgs.fontconfig}/bin:${pkgs.sway}/bin";
            ExecStart = "${getExe pkgs.sov}";
            StandardInput = "socket";
          };

          Unit = {
            Description = "An overlay that shows schemas for all workspaces to make navigation in sway easier";
            Documentation = "man:sov(1)";
            PartOf = ["graphical-session.target"];
            After = [cfg.systemdTarget];
            ConditionEnvironment = "WAYLAND_DISPLAY";
          };
        };

        sockets.sov = {
          Install.WantedBy = ["sockets.target"];

          Socket = {
            ListenFIFO = "%t/${cfg.socks.sov}";
            SocketMode = "0600";
            RemoveOnStop = "on";
            # If sov exits due to invalid input, clear the FIFO buffer as there
            # can be more invalid inputs that can cause sov to crash further.
            FlushPending = "yes";
          };
        };
      };
    })
  ])
