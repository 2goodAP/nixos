{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.desktop = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "a graphical DE or WM";

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
      {programs.dconf.enable = true;}

      (mkIf (cfg.manager == "wayland") {
        programs.nm-applet.enable = true;
        security.pam.services.swaylock.text = "auth include login";

        services = {
          blueman.enable = true;
          udisks2.enable = true;
        };
      })

      (mkIf (cfg.manager == "plasma") {
        programs.gnupg.agent.settings = {no-allow-external-cache = "";};

        environment = {
          systemPackages = [pkgs.wl-clipboard];

          plasma6.excludePackages = with pkgs.kdePackages; [
            ark
            elisa
            kate
            khelpcenter
            konsole
            okular
            plasma-browser-integration
            print-manager
          ];
        };

        services = {
          desktopManager.plasma6.enable = true;
          power-profiles-daemon.enable = !config.services.auto-cpufreq.enable;
        };
      })
    ]);
}
