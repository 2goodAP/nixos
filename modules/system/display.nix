{
  config,
  inputs',
  lib,
  pkgs,
  ...
}: {
  options.tgap.system = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    ddcci.enable =
      mkEnableOption "DDC/CI kernel module and utils"
      // {
        default = true;
      };

    desktop = {
      enable = mkEnableOption "a graphical DE or WM";

      manager = mkOption {
        type = types.enum ["plasma" "niri"];
        description = ''
          The program(s) used to provide a desktop session.
          Currently supports "plasma" desktop or "niri" compositor.
        '';
      };
    };
  };

  config = let
    cfg = config.tgap.system;
    inherit (lib) mkIf mkMerge optionals;
  in
    mkMerge [
      (mkIf cfg.ddcci.enable {
        environment.systemPackages = [pkgs.ddcutil];

        boot = {
          extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
          kernelModules = ["ddcci"];
        };
      })

      (mkIf cfg.desktop.enable (mkMerge [
        {programs.dconf.enable = true;}

        (mkIf (cfg.desktop.manager == "niri") {
          security.pam.services.hyprlock.text = "auth include login";

          environment.systemPackages =
            optionals
            (builtins.elem "nvidia" config.services.xserver.videoDrivers)
            [pkgs.nvidia-vaapi-driver];

          programs = {
            nm-applet.enable = true;

            niri = {
              enable = true;
              package = inputs'.niri.packages.niri;
            };
          };

          services = {
            blueman.enable = true;
            udisks2.enable = true;
          };

          xdg.portal = {
            extraPortals = [pkgs.kdePackages.xdg-desktop-portal-kde];
            config.niri.default = ["kde" "gnome" "gtk"];
          };
        })

        (mkIf (cfg.desktop.manager == "plasma") {
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
      ]))
    ];
}
