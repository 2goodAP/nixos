# GUI configurations using KDE Plasma

{ pkgs, ... }:

{
  # Install and configure fonts.
  fonts.fonts = with pkgs; [
    fantasque-sans-mono
    open-sans
    roboto
    victor-mono
  ];


  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };


  programs.sway = let 
    # bash script to let dbus know about important env variables and
    # propogate them to relevent services run at the end of sway config.
    dbus-sway-environment = pkgs.writeTextFile {
      name = "dbus-sway-environment";
      destination = "/bin/dbus-sway-environment";
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

    extraPackages = with pkgs; [
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
      # Screensharing
      dbus-sway-environment
      # Terminal
      foot
      # Theme
      adwaita-qt
      capitaine-cursors
      libsForQt5.qt5ct
      papirus-icon-theme
    ];
  };


  qt5 = {
    platformTheme = "qt5ct";
    style = "adwaita";
  };


  services.greetd = let
    swayConfig = pkgs.writeText "greetd-sway-config" ''
      # `-l` activates layer-shell mode and `-c` runs the specified command.
      # Notice that `swaymsg exit` will run after gtkgreet exits.
      exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -c sway; swaymsg exit"

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

    settings = {
      default_session.command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
    };
  };


  sound.enable = true;


  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    wlr.enable = true;
  };
}
