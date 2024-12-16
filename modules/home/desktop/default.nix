{
  config,
  lib,
  osConfig,
  ...
}: {
  imports = [
    ./keepassxc
    ./speedcrunch
    ./wayland
    ./applications.nix
    ./firefox.nix
  ];

  options.tgap.home.desktop.terminal = let
    inherit (lib) mkOption types;
  in
    mkOption {
      type = types.nullOr (types.enum ["wezterm"]);
      default = "wezterm";
      description = "The terminal emulator program to install.";
    };

  config = let
    cfg = config.tgap.home.desktop;
    osCfg = osConfig.tgap.system.desktop;
    inherit (lib) mkIf;
  in
    mkIf (osCfg.enable && cfg.terminal == "wezterm") {
      programs.wezterm = {
        enable = true;

        extraConfig = ''
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
            default_gui_startup_args = { "connect", "unix" },
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
              bottom = 0,
              left = 5,
              right = 1,
              top = 4,
            },
          }

          return config
        '';
      };
    };
}
