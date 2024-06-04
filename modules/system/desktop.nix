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
        type = types.nullOr types.str;
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
    inherit (lib) getExe getExe' mkIf mkMerge optionalAttrs optionals;
  in
    mkIf cfg.enable (mkMerge [
      {programs.dconf.enable = true;}

      (mkIf (cfg.manager == "wayland") {
        programs.nm-applet.enable = true;
        security.pam.services.swaylock.text = "auth include login";

        services = {
          blueman.enable = true;
          udisks2.enable = true;
        };
      })

      (mkIf (cfg.manager == "plasma") {
        programs.gnupg.agent.settings = {no-allow-external-cache = "";};

        environment = {
          systemPackages = [pkgs.wl-clipboard];

          plasma6.excludePackages = with pkgs.kdePackages; [
            ark
            elisa
            kate
            khelpcenter
            konsole
            okular
            plasma-browser-integration
            print-manager
          ];
        };

        services = {
          desktopManager.plasma6.enable = true;
          power-profiles-daemon.enable = !config.services.tlp.enable;
        };
      })

      (let
        steam =
          (
            if cfg.gaming.steam.enable
            then pkgs.steam
            else pkgs.steamPackages.steam-fhsenv-without-steam
          )
          .override {
            extraEnv = {};
            extraLibraries = ps:
              with ps; [
                gamemode
                keyutils
                libkrb5
                libpulseaudio
                mangohud
                stdenv.cc.cc.lib
              ];
          };
      in
        mkIf cfg.gaming.enable (mkMerge [
          {
            programs = {
              gamemode.enable = true;

              gamescope = {
                enable = true;
                capSysNice = true;

                args =
                  [
                    "--expose-wayland"
                    "--rt"
                    "--adaptive-sync"
                    "--force-grab-cursor"
                  ]
                  ++ (optionals (cfg.gaming.vkDeviceID != null) [
                    "--prefer-vk-device ${cfg.gaming.vkVendorID}:${cfg.gaming.vkDeviceID}"
                  ]);

                env = optionalAttrs config.hardware.nvidia.prime.offload.enable {
                  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
                  __NV_PRIME_RENDER_OFFLOAD = "1";
                  __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
                  __VK_LAYER_NV_optimus = "NVIDIA_only";
                };
              };
            };

            environment.systemPackages = let
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
                  -f, --fullscreen                   make the gamescope window fullscreen
                  -F, --fps-limit <fps-limit>        framerate-limit passed to gamescope
                  -P, --proton-build <proton-build>  name of the proton build to use from
                                                     $STEAM_COMPAT_CLIENT_INSTALL_PATH
                                                     (only GE builds supported)
                  -m, --mangohud                     enable mangohud overlay
                  -o, --opengl                       enable OpenGL specific tweaks
                      --help                         display this help
                EOF
                }

                declare {PREFIX,FULLSCREEN,PROTON_BUILD,MANGOHUD}=""
                WIDTH=2560 HEIGHT=1440 REF_RATE=165 FPS_LIMIT=$REF_RATE OPENGL=false

                OPTS="$( \
                  ${getExe' pkgs.util-linux "getopt"} --name "''${0##*/}" \
                  --options 'p:w:h:r:F:P:fmo' --longoptions 'help,prefix:,width:' \
                  --longoptions 'height:,refresh-rate:,fps-limit:,proton-build:' \
                  --longoptions 'fullscreen,mangohud,opengl' \
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
                      MANGOHUD="${getExe' pkgs.mangohud "mangohud"}"
                      shift
                      ;;
                    -o|--opengl)
                      OPENGL=true
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

                if [[ -z "$1" ]]; then
                  ${getExe' pkgs.coreutils "echo"} "''${0##*/}: missing game-dir argument
                Please specify the absolute path to the game's root directory." >&2
                  show_help >&2
                  exit 1
                elif [[ -z "$2" ]]; then
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

                # Proton Build

                export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam/compatibilitytools.d"
                if [[ -z "$PROTON_BUILD" ]]; then
                  PROTON_BUILD="$(basename $(${getExe' pkgs.coreutils "ls"} -drv \
                    "$STEAM_COMPAT_CLIENT_INSTALL_PATH"/GE-Proton*))"
                elif [[ ! -d "$STEAM_COMPAT_CLIENT_INSTALL_PATH/$PROTON_BUILD" ]]; then
                    export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam/steamapps/common"
                fi

                # Prefix

                if [[ -z "$PREFIX" ]]; then
                  PREFIX="$(${getExe' pkgs.coreutils "basename"} "$GAME_DIR")"
                fi
                export STEAM_COMPAT_DATA_PATH="$HOME/Wine/Prefixes/''${PREFIX// /_}"
                if [[ ! -d "$STEAM_COMPAT_DATA_PATH" ]]; then
                  ${getExe' pkgs.coreutils "mkdir"} -p "$STEAM_COMPAT_DATA_PATH"
                fi

                # OpenGL Specific
                # ---------------

                if [[ "$OPENGL" == true && -n "$MANGOHUD" ]]; then
                  MANGOHUD+=" --dlsym"
                fi

                # Launch the game
                # ---------------

                cd "$GAME_DIR"
                PROTON_HEAP_DELAY_FREE=1 PULSE_LATENCY_MSEC=30 \
                  ${config.security.wrapperDir}/gamescope \
                  -W $(("$WIDTH")) -H $(("$HEIGHT")) -r $(("$REF_RATE")) \
                  --framerate-limit $(("$FPS_LIMIT")) -o 60 $FULLSCREEN -- \
                  ${getExe' pkgs.gamemode "gamemoderun"} \
                  ${getExe' pkgs.util-linux "setpriv"} --inh-caps -sys_nice -- \
                  $MANGOHUD ${getExe steam.run} \
                  "$STEAM_COMPAT_CLIENT_INSTALL_PATH/$PROTON_BUILD/proton" run \
                  "$GAME_DIR/$EXE_PATH" "$@" &> "/tmp/$PREFIX.log" &
                disown $!
              '';
            in [
              launch-game
              steam.run
            ];
          }

          (mkIf cfg.gaming.steam.enable {
            programs.steam = {
              enable = true;
              gamescopeSession = {inherit (config.programs.gamescope) args enable env;};
              package = steam;
            };
          })
        ]))
    ]);
}
