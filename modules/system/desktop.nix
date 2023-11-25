{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.desktop = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "Whether or not to enable a graphical DE or WM.";

    gaming = {
      enable = mkEnableOption "Whether or not to enable gaming-related features.";

      vkDeviceID = mkOption {
        type = types.str;
        default = null;
        description = "The vulkan deviceID of the preferred GPU to use with gamescope.";
      };

      vkVendorID = mkOption {
        type = types.enum ["1002" "13B5" "8086" "10DE"];
        default = "10DE";
        description = "The vulkan vendorID of the preferred GPU to use with gamescope.";
      };
    };

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
    inherit (lib) mkIf mkMerge optionalAttrs;
  in
    mkIf cfg.enable (mkMerge [
      {
        programs = {
          dconf.enable = true;
          gnupg.agent.pinentryFlavor = "qt";
        };
      }

      (mkIf (cfg.manager == "wayland") {
        security.pam.services.swaylock.text = "auth include login";
      })

      (mkIf (cfg.manager == "plasma") {
        environment = {
          systemPackages = [pkgs.wl-clipboard];

          plasma5.excludePackages = with pkgs.libsForQt5; [
            ark
            elisa
            khelpcenter
            konsole
            okular
            oxygen
            plasma-browser-integration
            print-manager
          ];
        };

        services = {
          power-profiles-daemon.enable = !config.services.tlp.enable;

          xserver.desktopManager.plasma5 = {
            enable = true;
            phononBackend = "vlc";
            runUsingSystemd = true;
            useQtScaling = true;
          };
        };
      })

      (mkIf cfg.gaming.enable {
        programs = {
          gamescope = {
            enable = true;
            capSysNice = true;

            args = [
              "--rt"
              "--prefer-vk-device ${cfg.gaming.vkVendorID}:${cfg.gaming.vkDeviceID}"
              "--hdr-enabled"
              "--force-grab-cursor"
              "--adaptive-sync"
            ];

            env = optionalAttrs config.hardware.nvidia.prime.offload.enable {
              __GLX_VENDOR_LIBRARY_NAME = "nvidia";
              __NV_PRIME_RENDER_OFFLOAD = "1";
              __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
              __VK_LAYER_NV_optimus = "NVIDIA_only";
            };
          };

          steam.gamescopeSession = {
            inherit (config.programs.gamescope) args enable env;
          };
        };
      })
    ]);
}
