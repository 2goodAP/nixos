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
      environment.systemPackages = [pkgs.kitty];

      fonts.fonts = with pkgs; [
        caskaydia-cove-nerd-font
        fira-code-nerd-font
        noto-nerd-font
        open-sans
        roboto
      ];

      programs = {
        dconf.enable = true;
        gnupg.agent.pinentryFlavor = "qt";
      };

      services = {
        power-profiles-daemon.enable = !config.services.tlp.enable;

        xserver.desktopManager.plasma5 = {
          enable = true;
          runUsingSystemd = true;
          useQtScaling = true;
          excludePackages = with pkgs.libsForQt5; [
            ark
            elisa
            khelpcenter
            konsole
            okular
            oxygen
            plasma-browser-integration
          ];
        };
      };
    };
}
