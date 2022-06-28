# GUI configurations using KDE Plasma

{ driver ? "modesetting", ... }:

{
  sound.enable = true;


  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Configure keymap in X11.
    layout = "us";
    xkbOptions = "eurosign:e";

    # Enable touchpad support.
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
      touchpad = {
        clickMethod = "clickfinger";
        naturalScrolling = true;
      };
    };

    # Enable selected video drivers.
    videoDrivers = [ driver ];

    # Use SDDM as the display manager.
    displayManager.sddm = {
      enable = true;
      theme = "breeze";
      settings = {
        General = {
	        DisplayServer = "wayland";
            GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell";
	      };
	      Theme = { CursorTheme = "Breeze_Snow"; };
	      Wayland = {
	        CompositorCommand = "kwin_wayland --no-lockscreen --inputmethod qt5-virtualkeyboard";
	      };
      };
    };

    # Use KDE Plasma as the desktop environment.
    desktopManager.plasma5.enable = true;
  };


  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };
}
