# GUI configurations using KDE Plasma
{
  config,
  pkgs,
  ...
}: {
  # Install and configure fonts.
  fonts.fonts = with pkgs; [
    caskaydia-cove-nerd-font
    fira-code-nerd-font
    noto-nerd-font
    open-sans
    roboto
  ];

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  programs.sway = let
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
  in {
    enable = true;
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
      # Firefox wayland environment variable.
      export MOZ_ENABLE_WAYLAND=1
      export MOZ_USE_XINPUT2=1
      # OpenGL Variables.
      export GBM_BACKEND=nvidia-drm
      export __GL_GSYNC_ALLOWED=0
      export __GL_VRR_ALLOWED=0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
    '';

    extraPackages =
      [
        # Screensharing
        dbus-sway-environment
      ]
      ++ (with pkgs; [
        # Bar
        waybar
        libappindicator-gtk3
        # Desktop
        dex
        mako
        rofi-wayland
        swaybg
        wob
        # Display
        gammastep
        kanshi
        # Input
        clipman
        wev
        wl-clipboard
        ydotool
        # Locking
        swayidle
        swaylock
        # Media
        imv
        mpv
        # Screenshot
        sway-contrib.grimshot
        # Terminal
        foot
        # Theme
        adwaita-qt
        capitaine-cursors
        libsForQt5.qt5ct
        papirus-icon-theme
        # Volume
        pavucontrol
      ]);
  };

  qt = {
    platformTheme = "qt5ct";
    style = "adwaita";
  };

  services = {
    greetd = let
      swayOpts = builtins.toString config.programs.sway.extraOptions;

      # swaywm wrapper with correct configuration.
      swayrun = pkgs.writeScript "swayrun" ''
        ${config.programs.sway.extraSessionCommands}

        exec ${pkgs.sway}/bin/sway ${swayOpts} -D noscanout "$@"
      '';

      # A minimal sway config for launching gtkgreet.
      swayConfig = pkgs.writeText "greetd-sway-config" ''
        # Autostarts
        # ----------

        # `-l` activates layer-shell mode and `-c` runs the specified command.
        # Notice that `swaymsg exit` will run after gtkgreet exits.
        exec ${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -c ${swayrun}; swaymsg exit

        # Inputs
        # ------

        # General
        input '*' {
            xkb_layout 'us,np'
            xkb_variant 'altgr-intl,'
            accel_profile flat
        }

        # Keyboards
        input '1:1:AT_Translated_Set_2_keyboard' {
            xkb_layout 'us,np'
            xkb_variant 'colemak_dh,'
        }

        # Pointers
        input '1267:12433:ELAN0504:01_04F3:3091_Touchpad' {
            accel_profile adaptive
            click_method clickfinger
            dwt enable
            natural_scroll enabled
            tap enabled
        }

        # Keybindings
        # -----------

        # Nagbar keys
        set $exit e
        set $reboot r
        set $shutdown s
        set $dismiss d

        # Session control using swaynag.
        mode "nagbar" {
          # Exit out of swaywm.
          bindsym --to-code $exit exit
          # Reboot the machine
          bindsym --to-code $reboot exec "systemctl -i reboot"
          # Shutdown the machine
          bindsym --to-code $shutdown exec "systemctl -i poweroff"
          # Quit out of the nagbar.
          bindsym --to-code $dismiss exec killall swaynag; mode "default"
        }

        bindsym --to-code Mod4+Shift+e \
          exec swaynag -t "warning" -f "NotoSans Nerd Font" \
          -m "You pressed the exit shortcut. Select the action you want to perform." \
          -s "" -B "Shutdown ($shutdown)" "systemctl -i poweroff" \
          -B "Reboot ($reboot)" "systemctl -i reboot" \
          -B "Exit Sway ($exit)" "swaymsg exit" \
          -Z "Dismiss Nagbar ($dismiss)" "swaymsg mode default"; mode "nagbar"
      '';
    in {
      enable = true;

      settings = {
        default_session.command = ''
          ${pkgs.sway}/bin/sway ${swayOpts} --config ${swayConfig}
        '';
      };
    };

    xserver = {
      videoDrivers = ["nvidia"];
      layout = "us,us,np";
      xkbVariant = "altgr-intl,colemak_dh,";
      xkbOptions = "grp:alt_shift_toggle";
    };
  };

  sound.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    wlr.enable = true;
  };
}
