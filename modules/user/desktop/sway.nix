{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.desktop.sway = let
    inherit (lib) mkOption types;
  in {
    enable = mkOption {
      description = "Whether or not to enable swaywm and supporting programs.";
      type = types.bool;
      default = false;
    };

    systemdTarget = mkOption {
      description = "Systemd target to bind to.";
      type = types.str;
      default = "sway-session.target";
    };

    extraPackages = mkOption {
      description = "Extra packages to install along with swaywm.";
      type = types.listOf types.package;
      default = [];
    };
  };

  config = let
    cfg = config.tgap.desktop.sway;
    inherit (lib) mkIf;
    writeIf = cond: msg:
      if cond
      then msg
      else "";
  in
    mkIf cfg.enable {
      wayland.windowManager.sway = {
        enable = true;
        swyanag.enable = true;
        wrapperFeatures.gtk = true;
        extraOptions = ["--unsupported-gpu"];

        extraSessionCommands = ''
          # Set wlroots renderer to Vulkan to avoid flickering.
          #export WLR_RENDERER=vulkan

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

          ${writeIf (builtins.elem "nvidia" config.services.xserver.videoDrivers) ''
            # OpenGL Variables.
            export GBM_BACKEND=nvidia-drm
            export __GL_GSYNC_ALLOWED=1
            export __GL_VRR_ALLOWED=1
            export __GLX_VENDOR_LIBRARY_NAME=nvidia
          ''}
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
            target = cfg.systemdTarget;
          };
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
          latitude = 0;
          longitude = 0;
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

      systemd = {
        services.wob = {
          enable = true;
          description = "A lightweight overlay volume/backlight/progress/anything bar for Wayland";
          documentation = "man:wob(1)";
          partOf = [cfg.systemdTarget];
          after = [cfg.systemdTarget];
          serviceConfig = {
            StandardInput = "socket";
            ExecStart = "${pkgs.wob}/bin/wob";
          };
          wantedBy = [cfg.systemdTarget];
        };

        sockets.wob = {
          enable = true;
          socketConfig = {
            ListenFIFO = "%t/wob.sock";
            SocketMode = 0600;
          };
          wantedby = [cfg.systemdTarget];
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
        ])
        ++ cfg.extraPackages;
    };
}
