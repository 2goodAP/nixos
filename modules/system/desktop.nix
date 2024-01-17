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
      steam.enable = mkEnableOption "Whether or not to install the Steam desktop app.";

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
    inherit (lib) getExe getExe' mkIf mkMerge optionalAttrs optionalString;
  in
    mkIf cfg.enable (mkMerge [
      {
        programs = {
          dconf.enable = true;
          gnupg.agent.pinentryFlavor = "qt";
          nm-applet.enable = true;
        };
      }

      (mkIf (cfg.manager == "wayland") {
        security.pam.services.swaylock.text = "auth include login";

        services = {
          blueman.enable = true;
          udisks2.enable = true;
        };
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

      (let
        steam = pkgs.steam.override {
          extraLibraries = pkgs:
            with pkgs; [
              xorg.libXcursor
              xorg.libXi
              xorg.libXinerama
              xorg.libXScrnSaver
              libpng
              libpulseaudio
              libvorbis
              stdenv.cc.cc.lib
              libkrb5
              keyutils

              gamemode
              mangohud
            ];
        };
      in
        mkIf cfg.gaming.enable {
          programs = {
            gamescope = {
              enable = true;
              capSysNice = true;

              args = [
                "--expose-wayland"
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

            steam = {
              enable = cfg.gaming.steam.enable;
              gamescopeSession = {inherit (config.programs.gamescope) args enable env;};
              package = steam;
            };
          };

          environment.systemPackages = let
            nvidia = builtins.elem "nvidia" config.services.xserver.videoDrivers;

            launch-game = pkgs.writeScriptBin "launch-game" ''
              #!${getExe pkgs.bash}

              # Command-line parsing
              # --------------------

              show_help() {
              ${getExe' pkgs.coreutils "cat"} << EOF

              Usage:
                ''${0##*/} [options] <game-dir> <exe-path> [-- game-opts]

              A command-line game launcher to launch games with added bells-and-whistles.

              Options:
                -p, --prefix <prefix>              name of the proton prefix to use from
                                                   $HOME/Wine/Prefixes
                -w, --width <width>                output-width passed to gamescope
                -h, --height <height>              output-height passed to gamescope
                -r, --refresh-rate <ref-rate>      nested-refresh-rate passed to gamescope
                -F, --fps-limit <fps-limit>        framerate-limit passed to gamescope
                -P, --proton-build <proton-build>  name of the proton build to use from
                                                   $STEAM_COMPAT_CLIENT_INSTALL_PATH
                                                   (only GE builds supported)
                -m, --mangohud                     enable mangohud overlay
                -h, --help                         display this help
              EOF
              }

              declare {PREFIX,MANGOHUD,FULLSCREEN}=""
              WIDTH=2560 HEIGHT=1440 REF_RATE=165 FPS_LIMIT=$REF_RATE

              export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam/compatibilitytools.d"
              PROTON_BUILD="$( \
                ${getExe' pkgs.coreutils "ls"} "$STEAM_COMPAT_CLIENT_INSTALL_PATH" \
                | ${getExe' pkgs.coreutils "sort"} -rVt "-" \
                | ${getExe' pkgs.coreutils "head"} -n 1 \
              )"

              OPTS="$( \
                ${getExe' pkgs.util-linux "getopt"} --name "''${0##*/}" \
                --options 'p:w:h:r:F:P:fm' --longoptions 'help,prefix:,width:,height:' \
                --longoptions 'refresh-rate:,fps-limit:,proton-build:,fullscreen,mangohud' \
                -- "$@" \
              )"

              if [[ $? -ne 0 ]]; then
                  show_help >&2
                  exit 1
              fi

              eval set -- "$OPTS"
              while true; do
                  case "$1" in
                      -p|--prefix)
                          PREFIX="$2"
                          shift 2
                          ;;
                      -w|--width)
                          WIDTH="$2"
                          shift 2
                          ;;
                      -h|--height)
                          HEIGHT="$2"
                          shift 2
                          ;;
                      -r|--refresh-rate)
                          REF_RATE="$2"
                          shift 2
                          ;;
                      -F|--fps-limit)
                          FPS_LIMIT="$2"
                          shift 2
                          ;;
                      -P|--proton-build)
                          PROTON_BUILD="$2"
                          shift 2
                          ;;
                      -f|--fullscreen)
                          FULLSCREEN="-f"
                          shift
                          ;;
                      -m|--mangohud)
                          MANGOHUD=${getExe' pkgs.mangohud "mangohud"}
                          shift
                          ;;
                      --help)
                          show_help
                          exit 0
                          ;;
                      --)
                          shift
                          break
                          ;;
                  esac
              done

              if [ ! "$1" ]; then
                  ${getExe' pkgs.coreutils "echo"} "''${0##*/}: missing game-dir argument
              Please specify the absolute path to the game's root directory." >&2
                  show_help >&2
                  exit 1
              elif [ ! "$2" ]; then
                  ${getExe' pkgs.coreutils "echo"} "''${0##*/}: missing exe-path argument
              Please specify the relative path to the game's exe from game-dir." >&2
                  show_help >&2
                  exit 1
              fi

              GAME_DIR="$1"
              EXE_PATH="$2"
              shift 2

              # Default behaviors
              # -----------------

              if [ ! "$PREFIX" ]; then
                  PREFIX="$(${getExe' pkgs.coreutils "basename"} "$GAME_DIR")"
              fi
              export STEAM_COMPAT_DATA_PATH="$HOME/Wine/Prefixes/''${PREFIX// /_}"

              if [ ! -d "$STEAM_COMPAT_DATA_PATH" ]; then
                  ${getExe' pkgs.coreutils "mkdir"} -p "$STEAM_COMPAT_DATA_PATH"
              fi

              # Launch the game
              # ---------------

              cd "$GAME_DIR"
              ${optionalString nvidia "PROTON_ENABLE_NVAPI=1"} \
                PROTON_HEAP_DELAY_FREE=1 PULSE_LATENCY_MSEC=15  \
                ${config.security.wrapperDir}/gamescope -W "$WIDTH" -H "$HEIGHT" \
                -r "$REF_RATE" --framerate-limit "$FPS_LIMIT" -o 60 \
                ${optionalString (cfg.manager == "plasma") "$FULLSCREEN"} -- \
                ${getExe' pkgs.util-linux "setpriv"} --inh-caps -sys_nice -- \
                ${getExe steam.run} $MANGOHUD ${getExe' pkgs.gamemode "gamemoderun"} \
                "$STEAM_COMPAT_CLIENT_INSTALL_PATH/$PROTON_BUILD/proton" run \
                "$GAME_DIR/$EXE_PATH" "$@"
            '';
          in [launch-game];
        })
    ]);
}
