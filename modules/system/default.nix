{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./boot.nix
    ./desktop.nix
    ./laptop.nix
    ./network.nix
    ./programs
  ];

  options.tgap.system = let
    inherit (lib) mkEnableOption;
  in {
    apparmor.enable = mkEnableOption "Whether or not to enable apparmor.";

    audio.enable = mkEnableOption "Whether or not to enable audio-related services.";
  };

  config = let
    cfg = config.tgap.system;
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
          tlp.enable = true;

          xserver = {
            layout = "us,us,np";
            xkbVariant = "altgr-intl,colemak_dh,";
            xkbOptions = "grp:alt_caps_toggle";
          };
        };

        # This value determines the NixOS release from which the default
        # settings for stateful data on the system are taken.
        system.stateVersion = "23.11";
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

      (mkIf (cfg.plasma5.enable || cfg.programs.virtualization.enable) {
        hardware.opengl = {
          enable = true;
          driSupport32Bit = true;
        };
      })
    ];
}
