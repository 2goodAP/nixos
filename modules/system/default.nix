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

    bluetooth.enable = mkEnableOption "Whether or not to enable bluetooth-related services.";
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

          kmscon = {
            enable = true;
            fonts = [
              {
                name = "FiraCode Nerd Font";
                package = pkgs.fira-code-nerd-font;
              }
              {
                name = "CaskaydiaCove Nerd Font";
                package = pkgs.caskaydia-cove-nerd-font;
              }
            ];
            extraConfig = ''
              seats=all

              session-control=on

              xkb-layout=${config.xserver.layout}
              xkb-variant=${config.xserver.xkbVariant}
              xkb-options=${config.xserver.xkbOptions}

              drm=on
              hwaccel=on

              font-size=12
            '';
          };

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

      (mkIf (cfg.desktop.enable || cfg.programs.virtualization.enable) {
        hardware.opengl = {
          enable = true;
          driSupport32Bit = true;
        };
      })
    ];
}