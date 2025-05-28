{
  config,
  lib,
  pkgs,
  ...
}: let
  gsCfg = config.tgap.system.desktop.gaming.gamescope;
in {
  options.tgap.system.desktop.gaming = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "gaming-related features";
    steam.enable = mkEnableOption "the Steam desktop app";

    controllers = {
      dualsense.enable = mkEnableOption "utils for dualsense controllers";
      xbone.enable = mkEnableOption "kernel module and utils for new xbox controllers";
    };

    gamescope = {
      width = mkOption {
        type = types.int;
        default = 2560;
        description = "The width of the nested gamescope window.";
      };

      height = mkOption {
        type = types.int;
        default = 1440;
        description = "The height of the nested gamescope window.";
      };

      refreshRate = mkOption {
        type = types.int;
        default = 165;
        description = "The refresh rate for the nested gamescope window.";
      };

      extraArgs = mkOption {
        type = types.str;
        default = "-f";
        description = "Extra args for the gamescope command.";
      };

      finalArgs = mkOption {
        type = types.str;
        default =
          "-W ${builtins.toString gsCfg.width}"
          + " -H ${builtins.toString gsCfg.height}"
          + " -r ${builtins.toString gsCfg.refreshRate}"
          + " --framerate-limit ${builtins.toString gsCfg.refreshRate}"
          + " -o 60 ${gsCfg.extraArgs}";
        description = "Compiled/final args for the steam gamescope command.";
        readOnly = true;
      };

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
  };

  config = let
    dtCfg = config.tgap.system.desktop;
    cfg = dtCfg.gaming;
    inherit (lib) getExe getExe' mkIf mkMerge optionalAttrs optionals;

    steam =
      (
        if cfg.steam.enable
        then pkgs.steam
        else pkgs.steam-fhsenv-without-steam
      )
      .override {
        extraLibraries = ps:
          with ps; [
            freetype
            gamemode
            keyutils
            libkrb5
            libpulseaudio
            mangohud
            stdenv.cc.cc.lib
          ];
      };
  in
    mkIf (dtCfg.enable && cfg.enable) (mkMerge [
      {
        programs = {
          gamemode.enable = true;

          gamescope = {
            enable = true;
            capSysNice = true;

            args =
              [
                "--rt"
                "--adaptive-sync"
                "--force-grab-cursor"
              ]
              ++ optionals (gsCfg.vkDeviceID != null) [
                "--prefer-vk-device ${gsCfg.vkVendorID}:${gsCfg.vkDeviceID}"
              ];

            env = optionalAttrs config.hardware.nvidia.prime.offload.enable {
              __GLX_VENDOR_LIBRARY_NAME = "nvidia";
              __NV_PRIME_RENDER_OFFLOAD = "1";
              __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
              __VK_LAYER_NV_optimus = "NVIDIA_only";
            };
          };
        };

        environment.systemPackages = let
          umu-launch = pkgs.writeShellScriptBin "umu-launch" ''
            # Command-line parsing
            # --------------------

            function show_help() {
            ${getExe' pkgs.coreutils "cat"} << EOF
            Usage:
              ''${0##*/} [options] <game-dir> <exe-path> [-- game-opts]

            A command-line game launcher to launch games with added bells-and-whistles.

            Options:
              -e, --gamescope              enable gamescope nested composition
              -w, --width <width>          output-width passed to gamescope
              -h, --height <height>        output-height passed to gamescope
              -r, --ref-rate <ref-rate>    nested-refresh-rate passed to gamescope
              -l, --fps-limit <fps-limit>  framerate-limit passed to gamescope
              -g, --gs-args <gs-args>      extra args passed to gamescope
              -p, --prefix <prefix>        name of the proton prefix to use from
                                           $HOME/Wine/Prefixes
              -t, --proton <proton>        name of the proton build to use
              -m, --mangohud               enable mangohud overlay
              -o, --opengl                 enable OpenGL specific tweaks
              -x, --no-hidraw              disable HID raw and emulate xinput
                                           for controller compatibility
                  --help                   display this help
            EOF
            }

            declare {gs_cmd,prefix,proton,mh_cmd}=""
            declare gs_args='${gsCfg.extraArgs}' hidraw=1
            declare width=${builtins.toString gsCfg.width}
            declare height=${builtins.toString gsCfg.height}
            declare ref_rate=${builtins.toString gsCfg.refreshRate}
            declare fps_limit=${builtins.toString gsCfg.refreshRate}

            if ! opts="$( \
              ${getExe' pkgs.util-linux "getopt"} --name "''${0##*/}" \
              --options 'ew:h:r:l:g:p:t:mox' --longoptions 'help,gamescope' \
              --longoptions 'width:,height:,ref-rate:,fps-limit:,gs-args:' \
              --longoptions 'prefix:,proton:,mangohud,opengl,no-hidraw' \
              -- "$@" \
            )"; then
              show_help >&2
              exit 1
            fi

            eval set -- "$opts"
            while true; do
              case "$1" in
                -e|--gamescope)
                  gs_enable=true
                  shift
                  ;;
                -w|--width)
                  width="$2"
                  shift 2
                  ;;
                -h|--height)
                  height="$2"
                  shift 2
                  ;;
                -r|--ref-rate)
                  ref_rate="$2"
                  shift 2
                  ;;
                -l|--fps-limit)
                  fps_limit="$2"
                  shift 2
                  ;;
                -g|--gs-args)
                  gs_args="$2"
                  shift 2
                  ;;
                -p|--prefix)
                  prefix="$2"
                  shift 2
                  ;;
                -t|--proton)
                  proton="$2"
                  shift 2
                  ;;
                -m|--mangohud)
                  mangohud=true
                  shift
                  ;;
                -o|--opengl)
                  opengl=true
                  shift
                  ;;
                -x|--no-hidraw)
                  hidraw=0
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
            ${getExe' pkgs.coreutils "cat"} >&2 << EOF
            ''${0##*/}: missing game-dir argument
            Please specify the absolute path to the game's root directory.

            EOF
              show_help >&2
              exit 1
            elif [[ -z "$2" ]]; then
            ${getExe' pkgs.coreutils "cat"} >&2 << EOF
            ''${0##*/}: missing exe-path argument
            Please specify the relative path to the game's exe from game-dir.

            EOF
              show_help >&2
              exit 1
            fi

            game_dir="$1"
            exe_path="$2"
            shift 2

            set -e

            # Vars and Functions
            # ------------------

            if [[ -n ''${gs_enable+x} ]]; then
              gs_cmd="$(printf "%s %s %s" \
                "gamescope -W $((width)) -H $((height)) -r $((ref_rate)) -o 60" \
                "--framerate-limit $((fps_limit)) ''${mangohud+--mangoapp} $gs_args" \
                "-- ${getExe' pkgs.util-linux "setpriv"} --inh-caps -sys_nice --")"
            fi

            steam_root="$HOME/.local/share/Steam"
            prefix_root="$HOME/Wine/Prefixes"

            function find_latest_proton() {
              ${getExe' pkgs.coreutils "basename"} "$( \
                ${getExe' pkgs.coreutils "ls"} -drv \
                  "$1/$2"* \
                | head -n 1 \
              )"
            }

            # Proton
            # ------

            steam_proton='^Proton [-. [:alnum:]]+$'
            if [[ -z "$proton" ]]; then
              PROTONPATH="GE-Proton"
            elif [[ "$proton" =~ $steam_proton ]]; then
              PROTONPATH="$steam_root/steamapps/common/$proton"
            else
              PROTONPATH="$proton"
            fi
            export PROTONPATH

            # Prefix
            # ------

            if [[ -z "$prefix" ]]; then
              prefix="$(${getExe' pkgs.coreutils "basename"} "$game_dir")"
            fi
            export WINEPREFIX="$prefix_root/''${prefix// /_}"

            log_file="/tmp/$prefix.log"
            if [[ ! -x "$WINEPREFIX/pfx.lock" ]]; then
              ${getExe' pkgs.umu "umu-launcher"} "" &> "$log_file" || true
            else
              ${getExe' pkgs.coreutils "echo"} "" > "$log_file"
            fi

            # Mangohud
            # --------

            if [[ -n ''${mangohud+x} && -z ''${gs_enable+x} ]]; then
              mh_cmd="${getExe' pkgs.mangohud "mangohud"}"

              if [[ -n ''${opengl+x} ]]; then
                mh_cmd+=" --dlsym"
              fi
            fi

            # HidRaw and XInput Emulation
            # ---------------------------

            # First, determine the active Proton directory
            wine_exe="$steam_root/compatibilitytools.d"
            if [[ "$PROTONPATH" == "GE-Proton" ]]; then
              wine_exe+="/$(find_latest_proton "$wine_exe" 'GE-Proton')"
            elif [[ -x "$wine_exe/$PROTONPATH/files/bin/wine" ]]; then
              wine_exe+="/$PROTONPATH"
            elif [[ -x "$PROTONPATH/files/bin/wine" \
                    || -x "$PROTONPATH/dist/bin/wine" ]]; then
              wine_exe="$PROTONPATH"
            else
              wine_exe+="/$(find_latest_proton "$wine_exe" 'UMU-Proton')"
            fi

            # Then, set the wine executable path within
            if [[ -x "$wine_exe/dist/bin/wine" ]]; then
                wine_exe+="/dist/bin/wine"
            else
                wine_exe+="/files/bin/wine"
            fi

            steam-run "$wine_exe" reg add \
              "HKLM\System\CurrentControlSet\Services\winebus" \
              /t REG_DWORD /v DisableHidraw /d $((! hidraw)) /f &>> "$log_file"

            # Launch the game
            # ---------------

            cd "$game_dir" || exit 2
            PROTON_VERB="waitforexitandrun" PROTON_HEAP_DELAY_FREE=1 \
              $gs_cmd ${getExe' pkgs.gamemode "gamemoderun"} $mh_cmd \
              ${getExe pkgs.umu-launcher} "$exe_path" "$@" &>> "$log_file" &
            disown $!

            set +e
          '';
        in [
          steam.run
          pkgs.umu-launcher
          umu-launch
        ];
      }

      (mkIf cfg.controllers.dualsense.enable {
        environment.systemPackages = [pkgs.dualsensectl];

        services.udev.extraRules = ''
          ## DualSense Controller
          #  USB hidraw
          KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"
          # Bluetooth hidraw
          KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"

          ## DualSense Edge Controller
          # USB hidraw
          KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", TAG+="uaccess"
          # Bluetooth hidraw
          KERNEL=="hidraw*", KERNELS=="*054C:0DF2*", MODE="0660", TAG+="uaccess"
        '';
      })

      (mkIf (config.hardware.bluetooth.enable && cfg.controllers.xbone.enable) {
        hardware.xpadneo.enable = true;
      })

      (mkIf cfg.steam.enable {
        programs.steam = {
          enable = true;
          gamescopeSession = {inherit (config.programs.gamescope) args enable env;};
          package = steam;
        };
      })
    ]);
}
