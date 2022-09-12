# GUI configurations using KDE Plasma
{pkgs, ...}: {
  # Install and configure fonts.
  fonts.fonts = with pkgs; [fantasque-sans-mono open-sans roboto victor-mono];

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  programs.sway = let
    # A wrapper script to launch sway.
    swayrun = pkgs.writeTextFile rec {
      name = "swayrun";
      destination = "/bin/${name}";
      executable = true;

      text = ''
        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_DESKTOP=sway
        export XDG_CURRENT_DESKTOP=sway
        export MOZ_ENABLE_WAYLAND=1
        export CLUTTER_BACKEND=wayland
        export QT_QPA_PLATFORM=wayland-egl
        export QT_WAYLAND_FORCE_DPI=physical
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export ECORE_EVAS_ENGINE=wayland-egl
        export ELM_ENGINE=wayland_egl
        export _JAVA_AWT_WM_NONREPARENTING=1

        systemd-cat --identifier=sway ${pkgs.sway}/bin/sway $@
      '';
    };

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

    extraPackages =
      [
        # Screensharing
        dbus-sway-environment
        # Wrapper
        swayrun
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
        swaylock-effects
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

  qt5 = {
    platformTheme = "qt5ct";
    style = "adwaita";
  };

  services.greetd = let
    # A minimal sway config for launching gtkgreet.
    swayConfig = pkgs.writeText "greetd-sway-config" ''
      # `-l` activates layer-shell mode and `-c` runs the specified command.
      # Notice that `swaymsg exit` will run after gtkgreet exits.
      exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -c swayrun; swaymsg exit"

      # Nagbar keys
      set $exit e
      set $reboot r
      set $shutdown s
      set $dismiss d

      # Session control using swaynag.
      mode "nagbar" {
          # Exit out of swaywm.
          bindsym $exit exit
          # Reboot the machine
          bindsym $reboot exec "systemctl -i reboot"
          # Shutdown the machine
          bindsym $shutdown exec "systemctl -i poweroff"
          # Quit out of the nagbar.
          bindsym $dismiss exec killall swaynag; mode "default"
      }

      bindsym Mod4+Shift+e exec swaynag -t "warning" -f "FantasqueSansMono Nerd Font" \
          -m "You pressed the exit shortcut. Select the action you want to perform." \
          -s "" -B "Shutdown ($shutdown)" "systemctl -i poweroff" \
          -B "Reboot ($reboot)" "systemctl -i reboot" \
          -B "Exit Sway ($exit)" "swaymsg exit" \
          -Z "Dismiss Nagbar ($dismiss)" "swaymsg mode default"; mode "nagbar"
    '';
  in {
    enable = true;

    settings = {default_session.command = "swayrun --config ${swayConfig}";};
  };

  sound.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    wlr.enable = true;
  };
}
