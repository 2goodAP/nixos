{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ./applications.nix
    ./firefox
    ./wayland
    ./keepassxc
    ./speedcrunch
  ];

  options.tgap.home.desktop.terminal = let
    inherit (lib) mkOption types;
  in
    mkOption {
      type = types.nullOr (types.enum ["kitty" "wezterm"]);
      default = "wezterm";
      description = "The terminal emulator program to install.";
    };

  config = let
    cfg = config.tgap.home.desktop;
    osCfg = osConfig.tgap.system.desktop;
    inherit (lib) mkIf mkMerge;
  in
    mkIf osCfg.enable (mkMerge [
      {
        fonts.fontconfig.enable = true;

        home = {
          packages = with pkgs; [
            bibata-cursors
            (nerdfonts.override {
              fonts = [
                "CascadiaCode"
                "JetBrainsMono"
                "Monaspace"
              ];
            })
            noto-fonts
            noto-fonts-emoji-blob-bin
            noto-fonts-color-emoji
            noto-fonts-monochrome-emoji
          ];

          pointerCursor = {
            gtk.enable = true;
            name = "Bibata-Modern-Ice";
            package = pkgs.bibata-cursors;
            size = 28;
          };
        };
      }

      (mkIf (cfg.terminal == "kitty") {
        programs.kitty = {
          enable = true;

          extraConfig = ''
            # Opentype font features
            font_features CaskaydiaCoveNFM-Italic +calt +ss01
            font_features CaskaydiaCoveNFM-SemiBoldItalic +calt +ss01

            font_features FiraCodeNFM-Med +cv16 +cv18 +cv25 +cv26 +cv28 +cv29 +cv30 +cv31 +cv32 +onum +ss02 +ss03 +ss05 +ss06 +ss07 +ss08 +ss09 +zero
            font_features FiraCodeNFM-Bold +cv16 +cv18 +cv25 +cv26 +cv28 +cv29 +cv30 +cv31 +cv32 +onum +ss02 +ss03 +ss05 +ss06 +ss07 +ss08 +ss09 +zero

            font_features JetBrainsMonoNFM-Medium +calt +cv04 +cv16 +ss02 +ss19
            font_features JetBrainsMonoNFM-Bold +calt +cv04 +cv16 +ss02 +ss19

            font_features MonaspiceArNFM-Medium +liga +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08 +ss09
            font_features MonaspiceArNFM-Bold +liga +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08 +ss09
            font_features MonaspiceRnNFM-MediumItalic +liga +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08 +ss09
            font_features MonaspiceRnNFM-BoldItalic +liga +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08 +ss09

            ${builtins.readFile ./kitty/tokyonight_day.conf}
          '';
          settings = {
            # Fonts
            font_family = "JetBrainsMono NFM";
            bold_font = "JetBrainsMono NFM Bold";
            italic_font = "CaskaydiaCove NFM SemiLight Italic";
            bold_italic_font = "CaskaydiaCove NFM SemiBold Italic";

            font_size = "11.5";
            disable_ligatures = "cursor";

            # Cursor customization
            cursor = "none";
            cursor_text_color = "background";

            # Performance tuning
            input_delay = 1;
            repaint_delay = 7;
            sync_to_monitor = false;

            # Terminal bell
            enable_audio_bell = false;

            # Window layout
            enabled_layouts = "splits, grid, stack";
            window_padding_width = "0 2";
          };

          keybindings = let
            kitty_mod = "ctrl+shift";
          in {
            # Remap some overridden shortcuts to different keys.
            "${kitty_mod}+i" = "show_scrollback";
            "${kitty_mod}+apostrophe" = "next_layout";

            # Create new windows by smartly splitting the space used by existing ones.
            "${kitty_mod}+Return" = "launch --location=hsplit";
            "alt+shift+Return" = "launch --location=vsplit";

            # Use Vim keybindings for navigating and moving kitty windows.
            "${kitty_mod}+h" = "neighboring_window left";
            "${kitty_mod}+j" = "neighboring_window down";
            "${kitty_mod}+k" = "neighboring_window up";
            "${kitty_mod}+l" = "neighboring_window right";
            "${kitty_mod}+alt+h" = "move_window left";
            "${kitty_mod}+alt+j" = "move_window down";
            "${kitty_mod}+alt+k" = "move_window up";
            "${kitty_mod}+alt+l" = "move_window right";

            # Switch to the previously active kitty window.
            "${kitty_mod}+semicolon" = "nth_window -1";

            # Zoom into a window temporarily by switching to the stack layout.
            "${kitty_mod}+slash" = "toggle_layout stack";

            # Ask which OS window to move a tab into.
            "${kitty_mod}+n" = "detach_window ask";

            # = Navigate tabs using [ and ].
            "${kitty_mod}+[" = "previous_tab";
            "${kitty_mod}+]" = "next_tab";

            # Focus specific tab using number keys.
            "ctrl+alt+1" = "goto_tab 1";
            "ctrl+alt+2" = "goto_tab 2";
            "ctrl+alt+3" = "goto_tab 3";
            "ctrl+alt+4" = "goto_tab 4";
            "ctrl+alt+5" = "goto_tab 5";
            "ctrl+alt+6" = "goto_tab 6";
            "ctrl+alt+7" = "goto_tab 7";
            "ctrl+alt+8" = "goto_tab 8";
            "ctrl+alt+9" = "goto_tab 9";
            "ctrl+alt+0" = "goto_tab 0";

            # Switch to the previously active tab.
            "ctrl+alt+semicolon" = "goto_tab -1";

            # Ask which tab/OS window to move a kitty window into.
            "${kitty_mod}+m" = "detach_tab ask";
          };
        };
      })

      (mkIf (cfg.terminal == "wezterm") {
        programs.wezterm = {
          enable = true;

          extraConfig = ''
            local wezterm = require("wezterm")
            local config = wezterm.config_builder()

            -- Start font_rules configuration
            local font_rules = {}

            for _, intensity in ipairs({ "Bold", "Half", "Normal" }) do
              table.insert(font_rules, {
                intensity = intensity,
                italic = false,

                font = wezterm.font_with_fallback({
                  {
                    family = "MonaspiceAr NF",
                    weight = intensity == "Bold" and "Bold" or (intensity == "Half" and "DemiLight" or "Regular"),

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
                    family = "JetBrainsMono NF",
                    weight = intensity == "Bold" and "Bold" or (intensity == "Half" and "DemiLight" or "Regular"),

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
                    family = "MonaspiceRn NF",
                    italic = true,
                    weight = intensity == "Bold" and "Bold" or (intensity == "Half" and "DemiLight" or "Regular"),

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
                    family = "CaskaydiaCove NF",
                    italic = true,
                    weight = intensity == "Bold" and "DemiBold" or (intensity == "Half" and "Light" or "DemiLight"),

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
                  bg = "#f9f3ec",
                  fg = "#565178",
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
              font_rules = font_rules,
              color_scheme = "Rosé Pine Dawn (Gogh)",
              default_gui_startup_args = { "connect", "unix" },
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

              unix_domains = {
                { name = "unix" },
              },

              window_frame = {
                active_titlebar_bg = colors.title.active,
                font_size = 11.0,
                inactive_titlebar_bg = colors.title.inactive,
              },

              window_padding = {
                bottom = 0,
                left = 5,
                right = 1,
                top = 4,
              },
            }

            return config
          '';
        };
      })
    ]);
}
