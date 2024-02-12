{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./programs
    ./boot.nix
    ./desktop.nix
    ./laptop.nix
    ./network.nix
  ];

  options.tgap.system = let
    inherit (lib) mkEnableOption;
  in {
    apparmor.enable = mkEnableOption "Whether or not to enable apparmor.";
    audio.enable = mkEnableOption "Whether or not to enable audio-related services.";
  };

  config = let
    cfg = config.tgap.system;
    inherit (lib) mkDefault mkIf mkMerge;
  in
    mkMerge [
      {
        i18n.defaultLocale = "en_US.UTF-8";
        powerManagement.cpuFreqGovernor = mkDefault (
          if cfg.laptop.enable
          then "userspace"
          else "schedutil"
        );
        systemd.oomd.enableUserSlices = true;
        # This value determines the NixOS release from which the default
        # settings for stateful data on the system are taken.
        system.stateVersion = "23.11";

        console = {
          font = "${pkgs.terminus_font}/share/consolefonts/ter-d18n.psf.gz";
          useXkbConfig = true;
        };

        services = {
          fstrim.enable = true;
          printing.enable = true;

          xserver.xkb =
            (
              if cfg.laptop.enable
              then {
                layout = "us,us,np";
                variant = "altgr-intl,colemak_dh,";
              }
              else {
                layout = "us,np";
                variant = "altgr-intl,";
              }
            )
            // {options = "grp:ctrls_toggle";};
        };
      }

      (mkIf cfg.boot.encrypted-btrfs.enable {
        services = {
          btrfs.autoScrub = {
            enable = true;
            fileSystems = ["/"];
          };

          snapper = {
            snapshotRootOnBoot = true;
            configs = {
              root = {
                SUBVOLUME = "/";
                ALLOW_GROUPS = ["wheel"];
                SYNC_ACL = true;
                NUMBER_CLEANUP = true;
                NUMBER_LIMIT = 20;
                TIMELINE_CREATE = true;
                TIMELINE_CLEANUP = true;
                TIMELINE_LIMIT_HOURLY = "12";
                TIMELINE_LIMIT_DAILY = "5";
                TIMELINE_LIMIT_WEEKLY = "2";
                TIMELINE_LIMIT_MONTHLY = "1";
                TIMELINE_LIMIT_YEARLY = "0";
                EMPTY_PRE_POST_CLEANUP = true;
              };
              nix = {
                SUBVOLUME = "/nix";
                ALLOW_GROUPS = ["nixbld" "wheel"];
                SYNC_ACL = true;
                NUMBER_CLEANUP = true;
                NUMBER_LIMIT = 5;
                NUMBER_LIMIT_IMPORTANT = 5;
                TIMELINE_CREATE = true;
                TIMELINE_CLEANUP = true;
                TIMELINE_LIMIT_HOURLY = "12";
                TIMELINE_LIMIT_DAILY = "5";
                TIMELINE_LIMIT_WEEKLY = "2";
                TIMELINE_LIMIT_MONTHLY = "1";
                TIMELINE_LIMIT_YEARLY = "0";
                EMPTY_PRE_POST_CLEANUP = true;
              };
              home = {
                SUBVOLUME = "/home";
                ALLOW_GROUPS = ["users" "wheel"];
                SYNC_ACL = true;
                NUMBER_CLEANUP = true;
                NUMBER_LIMIT = 10;
                NUMBER_LIMIT_IMPORTANT = 5;
                TIMELINE_CREATE = true;
                TIMELINE_CLEANUP = true;
                TIMELINE_LIMIT_HOURLY = "12";
                TIMELINE_LIMIT_DAILY = "7";
                TIMELINE_LIMIT_WEEKLY = "2";
                TIMELINE_LIMIT_MONTHLY = "0";
                TIMELINE_LIMIT_YEARLY = "0";
                EMPTY_PRE_POST_CLEANUP = true;
              };
            };
          };
        };
      })

      (mkIf cfg.apparmor.enable {
        boot.kernelParams = ["lsm=landlock,lockdown,yama,apparmor,bpf"];

        security.apparmor = {
          enable = true;
          killUnconfinedConfinables = true;
        };
      })

      (mkIf cfg.audio.enable {
        services.pipewire = {
          enable = true;
          jack.enable = true;
          pulse.enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
        };
      })

      (mkIf (
          builtins.elem "nvidia" config.services.xserver.videoDrivers
          || cfg.programs.virtualization.enable
        ) {
          hardware.opengl = {
            enable = true;
            driSupport32Bit = true;
          };
        })
    ];
}
