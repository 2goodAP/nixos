{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  options.tgap.home.desktop = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    applications.enable = mkEnableOption "Whether or not to install common desktop apps.";
    steam.enable = mkEnableOption "Whether or not to install the Steam desktop app.";

    nixosApplications.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether or not to install desktop apps for NixOS only.";
    };
  };

  config = let
    cfg = config.tgap.home.desktop;
    osCfg = osConfig.tgap.system.desktop;
    inherit (lib) getExe getExe' mkIf mkMerge optionals;
  in
    mkIf osCfg.enable (mkMerge [
      (mkIf cfg.applications.enable {
        programs = {
          mpv = {
            enable = true;
            scripts = [pkgs.mpvScripts.mpris];
            config = {
              profile = "gpu-hq";
              vo = "gpu";
              hwdec = "auto-safe";
              ytdl-format = "ytdl-format=bestvideo[height<=?1920][fps<=?60]+bestaudio/best";
            };
          };

          sioyek = {
            enable = true;
            bindings = {
              next_page = "J";
              previous_page = "K";
              screen_down = "<C-j>";
              screen_up = "<C-k>";
              "goto_top_of_page;goto_right" = "<C-u>";
              "goto_bottom_of_page;goto_left" = "<C-d>";
            };
            config = {
              #shared_database_path = "$HOME/Nextcloud/Utilities/Sioyek/shared.db";
              startup_commands = "fit_page_to_width;toggle_visual_scroll";

              should_load_tutorial_when_no_other_file = "1";
              should_warn_about_user_key_override = "1";

              single_main_window_size = "960 960";
              main_window_size = "960 960";
              helper_window_size = "900 900";
              rerender_overview = "1";
              prerender_next_page_presentation = "1";

              search_url_a = "https://arxiv.org/search/?searchtype=all&source=header&query=";
              search_url_g = "https://scholar.google.com/scholar?hl=en&as_sdt=0%2C5&q=";
              search_url_s = "https://www.startpage.com/sp/search?abp=1&t=light&lui=english&prfe=8248e70cd4db24a655713454e687a846b356ab6136b42142c55afc10919ed7872a95b4fa5f8f923c4f56dfe54b1eabeced0c2df702f7264f2ea021fdf96e7d64aaf2ebc59ba008d23de46f0f&query=";
              middle_click_search_engine = "a";
              shift_middle_click_search_engine = "s";

              super_fast_search = "1";
              case_sensitive_search = "0";

              collapsed_toc = "1";
              create_table_of_contents_if_not_exists = "1";
              max_created_toc_size = "5000";
              sort_bookmarks_by_location = "1";

              zoom_inc_factor = "1.1";
              wheel_zoom_on_cursor = "1";

              background_color = "0.882 0.886 0.906";
              text_highlight_color = "0.6 0.655 0.875";
              search_highlight_color = "0.776 0.263 0.263";
              synctex_highlight_color = "0.345 0.459 0.224";
              custom_background_color = "0.882 0.886 0.906";
              custom_text_color = "0.216 0.376 0.749";
              status_bar_color = "0.180 0.490 0.914";
              status_bar_text_color = "0.914 0.914 0.925";
              page_separator_width = "2";
              ui_background_color = "0.769 0.784 0.855";
              ui_text_color = "0.216 0.376 0.749";
              ui_selected_background_color = "0.180 0.490 0.914";
              ui_selected_text_color = "0.914 0.914 0.925";

              ui_font = "Noto Sans Regular Nerd Font Complete";
              font_size = "14";
              status_bar_font_size = "14";
            };
          };

          zathura = {
            enable = false;
            options = {
              "font" = "Noto Sans Regular Nerd Font Complete 11";

              # Tokyo Night Day theme
              "notification-error-bg" = "#e9e9ed"; # tab_bar_bg
              "notification-error-fg" = "#f52a65"; # red
              "notification-warning-bg" = "#e9e9ed"; # tab_bar_bg
              "notification-warning-fg" = "#8c6c3e"; # yellow
              "notification-bg" = "#e9e9ed"; # tab_bar_bg
              "notification-fg" = "#587539"; # green

              "completion-bg" = "#c4c8da"; # inactive_tab_bg
              "completion-fg" = "#3760bf"; # fg
              "completion-group-bg" = "#99a7df"; # selection_bg
              "completion-group-fg" = "#3760bf"; # selection_fg
              "completion-highlight-bg" = "#2e7de9"; # active_tab_bg
              "completion-highlight-fg" = "#e9e9ec"; # active_tab_fg

              "index-bg" = "#c4c8da"; # inactive_tab_bg
              "index-fg" = "#3760bf"; # fg
              "index-active-bg" = "#2e7de9"; # active_tab_bg
              "index-active-fg" = "#e9e9ec"; # active_tab_fg

              "inputbar-bg" = "#2e7de9"; # active_tab_bg
              "inputbar-fg" = "#e9e9ec"; # active_tab_fg
              "statusbar-bg" = "#e9e9ed"; # tab_bar_bg
              "statusbar-fg" = "#8990b3"; # inactive_tab_fg

              "highlight-color" = "#99a7df"; # selection_bg
              "highlight-active-color" = "#c64343"; # color17

              "default-bg" = "#e1e2e7"; # bg
              "default-fg" = "#3760bf"; # fg
              "render-loading" = true;
              "render-loading-bg" = "#e1e2e7"; # bg
              "render-loading-fg" = "#3760bf"; # fg

              # Recolor book content's color
              "recolor-lightcolor" = "#e1e2e7"; # bg
              "recolor-darkcolor" = "#3760bf"; # fg
              "recolor" = false;
            };
          };
        };

        home.packages =
          (with pkgs; [
            gimp
            libreoffice-qt
            tor-browser-bundle-bin
            wev
          ])
          ++ (
            optionals cfg.nixosApplications.enable (with pkgs; [
              gparted
              nextcloud-client
              zoom-us
            ])
          );
      })

      (mkIf osCfg.gaming.enable {
        programs.mangohud = {
          enable = true;

          settings = {
            legacy_layout = false;

            toggle_fps_limit = "Shift_R+F8";
            toggle_logging = "Shift_R+F9";
            toggle_hud = "Shift_R+F10";

            gpu_stats = true;
            gpu_temp = true;
            gpu_core_clock = true;
            gpu_mem_clock = true;
            gpu_power = true;
            gpu_load_change = true;
            gpu_name = true;
            gpu_load_value = "50,90";
            vram = true;

            cpu_stats = true;
            cpu_temp = true;
            cpu_power = true;
            cpu_mhz = true;
            cpu_load_change = true;
            core_load_change = true;
            cpu_load_value = "50,90";
            procmem = true;
            procmem_shared = true;
            ram = true;

            fps = true;
            frame_timing = true;

            background_alpha = 0.8;
            font_size = 24;
            round_corners = 5;
            output_folder = "~/.local/share/MangoHud";
          };
        };

        home.packages = let
          steam-run =
            if cfg.steam.enable
            then pkgs.steam-run
            else pkgs.steamPackages.steam-fhsenv-without-steam.run;

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
              -f, --fps-limit <fps-limit>        framerate-limit passed to gamescope
              -P, --proton-build <proton-build>  name of the proton build to use from
                                                 $STEAM_COMPAT_CLIENT_INSTALL_PATH
                                                 (only GE builds supported)
              -m, --mangohud                     enable mangohud overlay
              -h, --help                         display this help
            EOF
            }

            declare {PREFIX,MANGOHUD}=""
            WIDTH=2560 HEIGHT=1440 REF_RATE=165 FPS_LIMIT=$REF_RATE

            export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam/compatibilitytools.d"
            PROTON_BUILD="$( \
              ${getExe' pkgs.coreutils "ls"} "$STEAM_COMPAT_CLIENT_INSTALL_PATH" \
              | ${getExe' pkgs.coreutils "sort"} -rVt "-" \
              | ${getExe' pkgs.coreutils "head"} -n 1 \
            )"

            OPTS="$( \
              ${getExe' pkgs.util-linux "getopt"} --name "''${0##*/}" \
              --options 'p:w:h:r:f:P:m' --longoptions 'prefix:,width:,height:' \
              --longoptions 'refresh-rate:,fps-limit:,proton-build:,mangohud,help' \
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
                    -f|--fps-limit)
                        FPS_LIMIT="$2"
                        shift 2
                        ;;
                    -P|--proton-build)
                        PROTON_BUILD="$2"
                        shift 2
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
            ${osConfig.security.wrapperDir}/gamescope -W "$WIDTH" -H "$HEIGHT" \
              -r "$REF_RATE" --framerate-limit "$FPS_LIMIT" -o 60 -- \
              ${getExe' pkgs.util-linux "setpriv"} --inh-caps '-sys_nice' -- \
              ${getExe' pkgs.gamemode "gamemoderun"} $MANGOHUD ${getExe steam-run} \
              "$STEAM_COMPAT_CLIENT_INSTALL_PATH/$PROTON_BUILD/proton" run \
              "$GAME_DIR/$EXE_PATH" "$@"
          '';
        in
          (with pkgs; [
            gamemode
            protonup-ng
            winetricks
            wineWowPackages.stagingFull
          ])
          ++ [launch-game steam-run]
          ++ (optionals cfg.steam.enable [pkgs.steam]);
      })
    ]);
}