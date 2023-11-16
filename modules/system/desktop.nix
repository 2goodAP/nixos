{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.desktop = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "Whether or not to enable a graphical DE or WM.";

    manager = mkOption {
      type = types.enum ["plasma" "wayland"];
      description = ''
        The program(s) used to provide a desktop session.
        Currently supports "plasma" desktop or "wayland" compositors.
      '';
    };
  };

  config = let
    cfg = config.tgap.system.desktop;
    inherit (lib) mkIf mkMerge;
  in
    mkIf cfg.enable (mkMerge [
      {
        programs = {
          dconf.enable = true;
          gnupg.agent.pinentryFlavor = "qt";
        };
      }

      (mkIf (cfg.manager == "plasma") {
        environment = {
          systemPackages = [pkgs.wl-clipboard];

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

        services = {
          power-profiles-daemon.enable = !config.services.tlp.enable;

          xserver.desktopManager.plasma5 = {
            enable = true;
            phononBackend = "vlc";
            runUsingSystemd = true;
            useQtScaling = true;
          };
        };
      })
    ]);
}
