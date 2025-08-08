{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./audio.nix
    ./boot.nix
    ./display.nix
    ./fonts.nix
    ./gaming.nix
    ./laptop.nix
    ./network.nix
    ./programs.nix
  ];

  options.tgap.system = let
    inherit (lib) mkEnableOption;
  in {
    apparmor.enable = mkEnableOption "apparmor" // {default = true;};
  };

  config = let
    cfg = config.tgap.system;
    inherit (lib) mkDefault mkIf mkMerge;
  in
    mkMerge [
      {
        powerManagement.cpuFreqGovernor = mkDefault (
          if cfg.laptop.enable
          then "userspace"
          else "schedutil"
        );
        # This value determines the NixOS release from which the default
        # settings for stateful data on the system are taken.
        system.stateVersion = "25.05";

        console = {
          font = "${pkgs.terminus_font}/share/consolefonts/ter-d18n.psf.gz";
          useXkbConfig = true;
        };

        i18n.extraLocaleSettings = {
          LC_TIME = "en_SC.UTF-8";
          LC_MEASUREMENT = "C.UTF-8";
        };

        services = {
          dbus.implementation = "broker";
          fstrim.enable = true;
          printing.enable = true;

          xserver.xkb =
            (
              if cfg.laptop.enable
              then {
                layout = "us,us,np";
                variant = "altgr-intl,colemak_dh_wide,";
              }
              else {
                layout = "us,np";
                variant = "altgr-intl,";
              }
            )
            // {options = "grp:menu_toggle,lv3:ralt_switch,grp_led:scroll";};
        };

        systemd = {
          oomd.enableUserSlices = true;
          sleep.extraConfig = "HibernateDelaySec=6h";
        };
      }

      (mkIf cfg.boot.encrypted-btrfs.enable {
        services = {
          btrfs.autoScrub = {
            enable = true;
            fileSystems = ["/"];
          };

          snapper.configs.home = {
            SUBVOLUME = "/home";
            ALLOW_GROUPS = ["users" "wheel"];
            SYNC_ACL = true;
            NUMBER_CLEANUP = true;
            NUMBER_LIMIT = 10;
            NUMBER_LIMIT_IMPORTANT = 5;
            TIMELINE_CREATE = true;
            TIMELINE_CLEANUP = true;
            TIMELINE_LIMIT_HOURLY = 12;
            TIMELINE_LIMIT_DAILY = 7;
            TIMELINE_LIMIT_WEEKLY = 2;
            TIMELINE_LIMIT_MONTHLY = 0;
            TIMELINE_LIMIT_YEARLY = 0;
            EMPTY_PRE_POST_CLEANUP = true;
          };
        };
      })

      (mkIf cfg.apparmor.enable {
        security.apparmor = {
          enable = true;
          killUnconfinedConfinables = true;
        };
      })

      (mkIf (
          builtins.elem "nvidia" config.services.xserver.videoDrivers
          || cfg.programs.virtualization.enable
        ) {
          hardware.graphics = {
            enable = true;
            enable32Bit = true;
          };
        })
    ];
}
