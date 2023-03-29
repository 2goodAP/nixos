{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.desktop = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Whether or not to enable Plasma5 DE.";
  };

  config = let
    cfg = config.tgap.system.desktop;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      fonts.fonts = with pkgs; [
        caskaydia-cove-nerd-font
        fira-code-nerd-font
        open-sans
        roboto
      ];

      environment.systemPackages = with pkgs; [
        foot
        kitty
      ];

      programs.dconf.enable = true;

      services = {
        power-profiles-daemon.enable = !config.services.tlp.enable;

        xserver = {
          enable = true;

          desktopManager.plasma5 = {
            enable = true;
            runUsingSystemd = true;
            useQtScaling = true;
            notoPackage = pkgs.noto-nerd-font;
            excludePackages = with pkgs.libsForQt5; [
              ark
              elisa
              khelpcenter
              konsole
              oxygen
              plasma-browser-integration
            ];
          };

          displayManager = {
            defaultSession = "plasmawayland";

            sddm = {
              enable = true;
              enableHidpi = true;
              autoNumlock = true;
              theme = "breeze";
              settings = {
                General = {
                  DisplayServer = "wayland";
                  GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell";
                };
                Theme = {CursorTheme = "Breeze_Snow";};
                Wayland = {
                  # CompositorCommand = "${pkgs.libsForQt5.kwin}/bin/kwin_wayland --no-global-shortcuts --no-lockscreen";
                  CompositorCommand = "${pkgs.sway}/bin/sway --unsupported-gpu";
                };
              };
            };
          };
        };
      };
    };
}
