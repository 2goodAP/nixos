{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./boot.nix
    ./laptop.nix
    ./network.nix
    ./programs
  ];

  options.tgap = let
    inherit (lib) mkEnableOption;
  in {
    apparmor.enable = mkEnableOption "Whether or not to enable apparmor.";

    audio.enable = mkEnableOption "Whether or not to enable audio-related services.";

    bluetooth.enable = mkEnableOption "Whether or not to enable bluetooth-related services.";

    gui.enable = mkEnableOption "Whether or not to enable gui-related services.";
  };

  config = let
    cfg = config.tgap;
    inherit (lib) mkIf mkMerge;
  in
    mkMerge [
      {
        i18n.defaultLocale = "en_US.UTF-8";

        console = {
          font = "${pkgs.terminus_font}/share/consolefonts/ter-d18n.psf.gz";
          useXkbConfig = true;
        };

        services = {
          printing.enable = true; # CUPS for printing documents.
          xserver = {
            layout = "us,us,np";
            xkbVariant = "altgr-intl,colemak_dh,";
            xkbOptions = "grp:alt_shift_toggle";
          };
        };

        # This value determines the NixOS release from which the default
        # settings for stateful data on the system are taken.
        system.stateVersion = "22.11";
      }

      (mkIf cfg.apparmor.enable {
        security.apparmor = {
          enable = true;
          killUnconfinedConfinables = true;
        };

        boot.kernelParams = ["lsm=landlock,lockdown,yama,apparmor,bpf"];
      })

      (mkIf cfg.audio.enable {
        services.pipewire = {
          enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
          jack.enable = true;
          pulse.enable = true;
        };
      })

      (mkIf cfg.bluetooth.enable {
        hardware = {
          bluetooth.enable = true;
          xpadneo.enable = true;
        };
      })

      (mkIf cfg.gui.enable {
        hardware.opengl = {
          enable = true;
          driSupport32Bit = true;
        };
      })
    ];
}
