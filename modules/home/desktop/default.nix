{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ./firefox
    ./keepassxc
    ./niri
    ./applications.nix
  ];

  options.tgap.home.desktop.terminal.name = let
    inherit (lib) mkOption types;
  in
    mkOption {
      type = types.nullOr (types.enum ["foot" "ghostty" "wezterm"]);
      default = "foot";
      description = "The terminal emulator program to install.";
    };

  config = let
    cfg = config.tgap.home;
    osCfg = osConfig.tgap.system;
    nushellDefault = osCfg.programs.defaultShell == "nushell";
    nushellPkg = config.programs.nushell.package;
    inherit (lib) mkIf mkMerge getExe optionalAttrs optionalString;
  in
    mkIf osCfg.desktop.enable (mkMerge [
      (mkIf (cfg.desktop.terminal.name == "foot") {
        programs.foot = {
          enable = true;
          settings = {
            cursor.blink = "yes";
            mouse.hide-when-typing = "yes";

            main = {
              shell =
                if osCfg.programs.enable
                then "${getExe config.programs.zellij.package} -l welcome"
                else if nushellDefault
                then "${getExe nushellPkg} -li"
                else "$SHELL";
              font = "IosevkaSpecial Nerd Font:size=12, JetbrainsMono Nerd Font:size=11.5";
              underline-offset = 1;
              dpi-aware = "yes";
              pad = "2x2 center";
              workers = osConfig.nix.settings.cores;
              utmp-helper = "${pkgs.libutempter}/lib/utempter/utempter";
            };

            colors = rec {
              background = "faf4ed";
              foreground = "575279";

              cursor = "${background} ${foreground}";
              selection-background = "dfdad9"; # gray (Highlight Med)

              regular0 = foreground; # black (Text)
              regular1 = "b4637a"; # red (Love)
              regular2 = "56949f"; # green (Foam)
              regular3 = "ea9d34"; # yellow (Gold)
              regular4 = "286983"; # blue (Pine)
              regular5 = "907aa9"; # magenta (Iris)
              regular6 = "d7827e"; # cyan (Rose)
              regular7 = "f2e9e1"; # white (Overlay)

              bright0 = "7c76a0"; # bright black (Lighter Text)
              bright1 = "df8aa0"; # bright red (Lighter Love)
              bright2 = "7ebcc7"; # bright green (Lighter Foam)
              bright3 = "ffc55c"; # bright yellow (Lighter Gold)
              bright4 = "538faa"; # bright blue (Lighter Pine)
              bright5 = "b8a1d2"; # bright magenta (Lighter Iris)
              bright6 = "ffaaa5"; # bright cyan (Lighter Rose)
              bright7 = "fffdf5"; # bright white (Lighter Overlay)

              flash = regular3;
              jump-labels = "${regular0} ${regular6}";
              search-box-match = "${foreground} ${regular0}";
              search-box-no-match = "${regular0} ${regular1}";
              urls = regular4;
            };

            key-bindings = {
              scrollback-up-page = "Control+Shift+b";
              scrollback-up-half-page = "Control+Shift+u";
              scrollback-down-page = "Control+Shift+f";
              scrollback-down-half-page = "Control+Shift+d";
              scrollback-home = "Control+Shift+m";
              scrollback-end = "Control+Shift+n";
              search-start = "Control+Shift+r";
              spawn-terminal = "Control+Shift+t";
              pipe-scrollback =
                ''[bash -c "f=$(mktemp) && cat - > $f && ''
                + ''foot $EDITOR $f; rm $f"] Control+Shift+s'';
              show-urls-launch = "Control+Shift+o";
              show-urls-copy = "Control+Shift+y";
              show-urls-persistent = "Control+Shift+e";
              unicode-input = "Control+Shift+i";
            };

            search-bindings = {
              unicode-input = "Control+Shift+i";
              scrollback-up-page = "Control+Shift+b";
              scrollback-up-half-page = "Control+Shift+u";
              scrollback-down-page = "Control+Shift+f";
              scrollback-down-half-page = "Control+Shift+d";
              scrollback-home = "Control+Shift+m";
              scrollback-end = "Control+Shift+n";
            };
          };
        };
      })

      (mkIf (cfg.desktop.terminal.name == "ghostty") {
        programs.ghostty = {
          enable = true;
          clearDefaultKeybinds = true;
          installBatSyntax = true;

          settings =
            optionalAttrs nushellDefault {command = "${getExe nushellPkg} -li";}
            // {
              font-size = 12;
              font-family = ["MonaspiceAr Nerd Font" "JetBrainsMono Nerd Font"];
              font-family-bold = ["MonaspiceAr Nerd Font" "JetBrainsMono Nerd Font"];
              font-family-italic = ["MonaspiceRn Nerd Font" "Cascadia Code"];
              font-family-bold-italic = ["MonaspiceRn Nerd Font" "Cascadia Code"];
              font-feature = "calt,cv04,cv16,liga,ss01,ss02,ss03,ss19,ss20";
              alpha-blending = "linear-corrected";
              adjust-cursor-thickness = "1";
              freetype-load-flags = "no-force-autohint";
              theme = "dark:rose-pine-moon,light:rose-pine-dawn";
              cursor-style-blink = true;
              mouse-hide-while-typing = true;
              unfocused-split-opacity = "0.93";
              unfocused-split-fill = "#232136";
              window-padding-balance = true;
              window-inherit-working-directory = true;
              window-inherit-font-size = true;
              window-decoration =
                if (osCfg.desktop.manager == "niri")
                then "none"
                else "server";
              window-theme = "ghostty";
              clipboard-trim-trailing-spaces = true;
              clipboard-paste-protection = true;
              shell-integration-features = "no-cursor";
              gtk-wide-tabs = false;
              desktop-notifications = false;

              keybind = [
                # Modified
                "ctrl+alt+j=resize_split:down,10"
                "ctrl+alt+h=resize_split:left,10"
                "ctrl+alt+l=resize_split:right,10"
                "ctrl+alt+k=resize_split:up,10"
                "ctrl+alt+e=equalize_splits"
                "ctrl+shift+u=write_screen_file:open"
                "ctrl+shift+n=new_split:down"
                "ctrl+shift+e=new_split:right"
                "ctrl+shift+,=goto_split:previous"
                "ctrl+shift+.=goto_split:next"
                "ctrl+shift+j=goto_split:down"
                "ctrl+shift+h=goto_split:left"
                "ctrl+shift+l=goto_split:right"
                "ctrl+shift+k=goto_split:up"
                "ctrl+shift+z=toggle_split_zoom"
                "ctrl+shift+bracket_right=reload_config"
                "ctrl+right_bracket=open_config"
                "alt+enter=toggle_fullscreen"
                "ctrl+shift+tab=previous_tab"
                "ctrl+tab=next_tab"
                "ctrl+shift+arrow_down=jump_to_prompt:1"
                "ctrl+shift+arrow_up=jump_to_prompt:-1"
                "ctrl+shift+o=new_window"

                # Default
                "ctrl+shift+a=select_all"
                "ctrl+shift+c=copy_to_clipboard"
                "ctrl+shift+i=inspector:toggle"
                "ctrl+shift+y=write_screen_file:paste"
                "ctrl+shift+p=toggle_command_palette"
                "ctrl+shift+q=quit"
                "ctrl+shift+t=new_tab"
                "ctrl+shift+v=paste_from_clipboard"
                "ctrl+shift+w=close_tab"
                "alt+1=goto_tab:1"
                "alt+2=goto_tab:2"
                "alt+3=goto_tab:3"
                "alt+4=goto_tab:4"
                "alt+5=goto_tab:5"
                "alt+6=goto_tab:6"
                "alt+7=goto_tab:7"
                "alt+8=goto_tab:8"
                "alt+9=last_tab"
                "alt+f4=close_window"
                "ctrl+equal=increase_font_size:1"
                "ctrl++=increase_font_size:1"
                "ctrl+-=decrease_font_size:1"
                "ctrl+0=reset_font_size"
                "ctrl+insert=copy_to_clipboard"
                "ctrl+page_down=next_tab"
                "ctrl+page_up=previous_tab"
                "shift+end=scroll_to_bottom"
                "shift+home=scroll_to_top"
                "shift+insert=paste_from_selection"
                "shift+page_down=scroll_page_down"
                "shift+page_up=scroll_page_up"
                "shift+arrow_down=adjust_selection:down"
                "shift+arrow_left=adjust_selection:left"
                "shift+arrow_right=adjust_selection:right"
                "shift+arrow_up=adjust_selection:up"
              ];
            };
        };
      })

      (mkIf (cfg.desktop.terminal.name == "wezterm") {
        programs.wezterm = {
          enable = true;

          extraConfig = let
            defaultProg =
              optionalString nushellDefault
              "default_prog = {'${getExe nushellPkg}', '-li'},";
          in ''
            local config = wezterm.config_builder()

            -- Start font_rules configuration
            local font_rules = {}

            for _, intensity in ipairs({ "Bold", "Half", "Normal" }) do
              table.insert(font_rules, {
                intensity = intensity,
                italic = false,

                font = wezterm.font_with_fallback({
                  {
                    family = "MonaspiceAr Nerd Font",
                    weight = intensity == "Bold" and "DemiBold" or (intensity == "Half" and "DemiLight" or "Regular"),

                    harfbuzz_features = {
                      "calt=1",
                      "liga=1",
                      "ss01=1",
                      "ss02=1",
                      "ss03=1",
                      "ss04=1",
                      "ss05=1",
                      "ss06=1",
                      "ss07=1",
                      "ss08=1",
                      "ss09=1",
                    },
                  },
                  {
                    family = "JetBrainsMono Nerd Font",
                    weight = intensity == "Bold" and "Bold" or (intensity == "Half" and "DemiLight" or "Medium"),

                    harfbuzz_features = {
                      "calt=1",
                      "cv04=1",
                      "cv16=1",
                      "ss02=1",
                      "ss19=1",
                    },
                  },
                }),
              })
            end

            for _, intensity in ipairs({ "Bold", "Half", "Normal" }) do
              table.insert(font_rules, {
                intensity = intensity,
                italic = true,

                font = wezterm.font_with_fallback({
                  {
                    family = "MonaspiceRn Nerd Font",
                    italic = true,
                    weight = intensity == "Bold" and "DemiBold" or (intensity == "Half" and "DemiLight" or "Regular"),

                    harfbuzz_features = {
                      "calt=1",
                      "liga=1",
                      "ss01=1",
                      "ss02=1",
                      "ss03=1",
                      "ss04=1",
                      "ss05=1",
                      "ss06=1",
                      "ss07=1",
                      "ss08=1",
                      "ss09=1",
                    },
                  },
                  {
                    family = "Cascadia Code",
                    italic = true,
                    weight = intensity == "Bold" and "DemiBold" or (intensity == "Half" and "DemiLight" or "Regular"),

                    harfbuzz_features = {
                      "calt=1",
                      "ss01=1",
                    },
                  },
                }),
              })
            end
            -- End font_rules configuration

            local colors = {
              tab = {
                active = {
                  fg = "#565178",
                  bg = "#f9f3ec",
                },
                inactive = {
                  fg = "#797492",
                  hover = "#f1e8e0",
                },
              },
              title = {
                active = "#c7c2bd",
                inactive = "#dbd5cf",
              },
            }

            config = {
              color_scheme = "Rosé Pine Dawn (Gogh)",
              command_palette_fg_color = colors.tab.inactive.fg,
              command_palette_bg_color = colors.title.inactive,
              cursor_blink_rate = 800,
              ${defaultProg}
              font_rules = font_rules,
              max_fps = 120,

              colors = {
                tab_bar = {
                  active_tab = {
                    bg_color = colors.tab.active.bg,
                    fg_color = colors.tab.active.fg,
                  },
                  inactive_tab = {
                    bg_color = colors.title.inactive,
                    fg_color = colors.tab.inactive.fg,
                  },
                  inactive_tab_hover = {
                    bg_color = colors.tab.inactive.hover,
                    fg_color = colors.tab.inactive.fg,
                  },
                  new_tab = {
                    bg_color = colors.title.active,
                    fg_color = colors.tab.inactive.fg,
                  },
                  new_tab_hover = {
                    bg_color = colors.title.active,
                    fg_color = colors.tab.active.fg,
                  },
                },
              },

              inactive_pane_hsb = {
                saturation = 0.9,
                brightness = 0.9,
              },

              unix_domains = {
                { name = "unix" },
              },

              window_frame = {
                active_titlebar_bg = colors.title.active,
                font_size = 11.0,
                inactive_titlebar_bg = colors.title.inactive,
              },

              window_padding = {
                bottom = 2,
                left = 5,
                right = 3,
                top = 4,
              },
            }

            return config
          '';
        };
      })
    ]);
}
