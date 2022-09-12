{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.machine.laptop;
  inherit (lib) mkEnableOption mkOption types;
in {
  options.machine.laptop = {
    enable = mkEnableOption {
      description = "Whether or not to enable laptop mode.";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.acpi
      pkgs.powertop
    ];

    programs.light.enable = true;

    services = {
      # Hibernate on low battery.
      # https://wiki.archlinux.org/title/laptop#Hibernate_on_low_battery_level
      udev.extraRules = ''
        # Suspend the system when battery level drops to 20% or lower
        SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-20]", RUN+="${pkgs.systemd}/bin/systemctl -i hibernate"
      '';

      logind.extraConfig = ''
        IdleAction=suspend-then-hibernate
        IdleActionSec=10min
        HandleLidSwitch=suspend-then-hibernate
        HandleLidSwitchDocked=ignore
        HandleHibernateKey=hibernate
        HandlePowerKey=hibernate
        HandleSuspendKey=suspend-ten-hibernate
      '';

      auto-cpufreq.enable = true;
      tlp.enable = true;
    };
  };
}
