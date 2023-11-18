{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.laptop = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "Whether or not to enable laptop mode.";

    model = mkOption {
      type = types.enum ["Acer Nitro AN515-51"];
      description = "The name of the laptop model. Must be in the format supported by nbfc-linux.";
    };
  };

  config = let
    cfg = config.tgap.system;
    inherit (lib) mkIf mkMerge;
  in
    mkIf cfg.laptop.enable (mkMerge [
      {
        environment = {
          systemPackages = with pkgs; [
            acpi
            nbfc-linux
            powertop
          ];

          etc."nbfc/nbfc.json" = {
            text = ''
              {"SelectedConfigId": "${cfg.model}"}
            '';
            mode = "0644";
          };
        };

        services = {
          # Hibernate on low battery.
          # https://wiki.archlinux.org/title/laptop#Hibernate_on_low_battery_level
          udev.extraRules = ''
            # Suspend the system when battery level drops to 20% or lower
            SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-20]", RUN+="${pkgs.systemd}/bin/systemctl -i hibernate"
          '';

          logind.extraConfig = ''
            HandleLidSwitch=suspend-then-hibernate
            HandleLidSwitchDocked=ignore
            HandleHibernateKey=hibernate
            HandlePowerKey=hibernate
            HandleSuspendKey=suspend-then-hibernate
          '';

          auto-cpufreq.enable = true;
        };

        systemd.services.nbfc_service = {
          enable = true;
          description = "NoteBook FanControl service";
          serviceConfig.Type = "simple";
          path = [pkgs.kmod];
          script = "${pkgs.nbfc-linux}/bin/nbfc_service";
          wantedBy = ["multi-user.target"];
        };
      }

      (mkIf (cfg.desktop.enable && cfg.desktop.manager == "wayland") {
        programs.light.enable = true;
      })
    ]);
}
