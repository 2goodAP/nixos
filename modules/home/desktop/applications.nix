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
    applications.enable = mkEnableOption "common desktop apps";
    gaming.enable = mkEnableOption "gaming related apps";

    nixosApplications.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether or not to install desktop apps for NixOS only.";
    };
  };

  config = let
    cfg = config.tgap.home.desktop;
    osCfg = osConfig.tgap.system;
    inherit (lib) mkIf mkMerge optionals;
  in
    mkIf osCfg.desktop.enable (mkMerge [
      (mkIf cfg.applications.enable {
        programs = {
          joplin-desktop = {
            enable = true;
            sync = {
              interval = "5m";
              target = "nextcloud";
            };
          };

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
              search_url_s =
                "https://us.startpage.com/sp/search"
                + "?&abp=1&t=device&lui=english"
                + "&sc=YyhP7EwjtGmX00&cat=web&prfe=fb87077e586ff7276b"
                + "486ed2188e443936775c3976b69d8f6550982948156465cb14"
                + "e689e00738659b51db36277aa4d52cb1b1912381b9f483ed3f"
                + "d0b226a682c306cf98c07621c8c236ad";
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

        home.packages = let
          pyVersion = "312";

          # Install python with `OpenTimelineIO` & `otio-kdenlive-adapter`
          # for Kdenlive's `OpenTimelineIO Export` & `OpenTimelineIO Import`.
          kdenlivePython =
            (builtins.getAttr "python${pyVersion}" pkgs).withPackages
            (ps: [
              ps.pip
              ps.setuptools

              (ps.buildPythonPackage rec {
                pname = "OpenTimelineIO";
                version = "0.17.0";
                format = "wheel";
                src = builtins.fetchurl {
                  url =
                    "https://files.pythonhosted.org/packages/95/c2/"
                    + "19fd190f4c584216e06860f4b26670ff8635bd9cb6339ab92d216a08aaae/"
                    + "${pname}-${version}-cp${pyVersion}-cp${pyVersion}"
                    + "-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
                  sha256 = "sha256:0kbg00ls0sfiffqqmi58nvz0zd89qfya0jgb9wnbd0fx7p7yzx54";
                };
              })

              (ps.buildPythonPackage rec {
                pname = "otio_kdenlive_adapter";
                version = "0.0.2";
                format = "wheel";
                src = builtins.fetchurl {
                  url =
                    "https://files.pythonhosted.org/packages/56/81/"
                    + "adc84754021a436458faa037e0b85366a283550bfef54ac2bcc85e39e161/"
                    + "${pname}-${version}-py3-none-any.whl";
                  sha256 = "sha256-cUJu1kb0PFWix9T3VakWaLPwpOZTIuJf0xRpBbIhhxk=";
                };
              })
            ]);
        in
          (with pkgs; [
            gimp
            libreoffice-fresh
            localsend
            tor-browser-bundle-bin
            wev
          ])
          ++ optionals cfg.nixosApplications.enable (
            (with pkgs; [
              gparted
              nextcloud-client
              zoom-us
            ])
            ++ [
              (pkgs.symlinkJoin {
                name = "kdenlive";
                paths = [pkgs.kdenlive];
                buildInputs = [pkgs.makeWrapper];
                postBuild = ''
                  wrapProgram $out/bin/kdenlive --suffix LD_LIBRARY_PATH : ${
                    lib.makeLibraryPath [pkgs.stdenv.cc.cc] + "64"
                  } --prefix PATH : ${lib.makeBinPath [kdenlivePython]}
                '';
              })
            ]
          );
      })

      (mkIf (osCfg.desktop.gaming.enable && cfg.gaming.enable) {
        programs.mangohud = {
          enable = true;

          settings = {
            no_display = true;
            legacy_layout = false;

            reload_cfg = "Shift_L+F1";
            toggle_fps_limit = "Shift_L+F2";
            toggle_logging = "Shift_L+F3";
            toggle_preset = "Shift_R+F10";
            toggle_hud_position = "Shift_R+F11";
            toggle_hud = "Shift_R+F12";

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

        home.packages =
          [osConfig.programs.gamescope.package]
          ++ (with pkgs; [
            protonup
            winetricks
            wineWowPackages.stagingFull
          ]);
      })
    ]);
}
