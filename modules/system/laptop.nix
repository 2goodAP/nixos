{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.laptop = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "laptop mode";

    model = mkOption {
      type = types.enum ["Acer Nitro AN515-51"];
      description = "The name of the laptop model. Must be in the format supported by nbfc-linux.";
    };
  };

  config = let
    cfg = config.tgap.system;
    inherit (lib) getExe' mkIf mkMerge;
  in
    mkIf cfg.laptop.enable (mkMerge [
      {
        environment.systemPackages = with pkgs; [
          acpi
          nbfc-linux
        ];

        services = {
          auto-cpufreq.enable = true;

          logind.extraConfig = ''
            HandleLidSwitch=suspend-then-hibernate
            HandleLidSwitchDocked=ignore
            HandleHibernateKey=hibernate
            HandlePowerKey=hibernate
            HandleSuspendKey=suspend-then-hibernate
          '';

          # Hibernate on low battery.
          # https://wiki.archlinux.org/title/laptop#Hibernate_on_low_battery_level
          udev.extraRules = ''
            # Suspend the system when battery level drops to 20% or lower
            SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-20]", RUN+="${pkgs.systemd}/bin/systemctl -i hibernate"
          '';
        };

        systemd.services.nbfc_service = let
          nbfc-json = pkgs.writeText "nbfc.json" ''
            {"SelectedConfigId": "${cfg.laptop.model}"}
          '';
        in {
          enable = true;
          description = "NoteBook FanControl service";
          serviceConfig.Type = "simple";
          path = [pkgs.kmod];
          wantedBy = ["multi-user.target"];
          script = ''
            ${getExe' pkgs.nbfc-linux "nbfc_service"} --config-file ${nbfc-json}
          '';
        };
      }

      (mkIf (cfg.desktop.enable && cfg.desktop.manager == "niri") {
        programs.light.enable = true;
      })
    ]);
}
