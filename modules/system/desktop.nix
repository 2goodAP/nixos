{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.plasma5 = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Whether or not to enable Plasma5 DE.";
  };

  config = let
    cfg = config.tgap.system.plasma5;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs; [
          kitty
          wl-clipboard
        ];

        plasma5.excludePackages = with pkgs.libsForQt5; [
          ark
          elisa
          khelpcenter
          konsole
          okular
          oxygen
          plasma-browser-integration
          print-manager
        ];
      };

      fonts.packages = [
        (pkgs.nerdfonts.override {
          fonts = ["CascadiaCode" "FiraCode" "Noto"];
        })
      ];

      programs = {
        dconf.enable = true;
        gnupg.agent.pinentryFlavor = "qt";
      };

      services = {
        power-profiles-daemon.enable = !config.services.tlp.enable;

        xserver.desktopManager.plasma5 = {
          enable = true;
          phononBackend = "vlc";
          runUsingSystemd = true;
          useQtScaling = true;
        };
      };
    };
}
