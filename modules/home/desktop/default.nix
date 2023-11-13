{
  config,
  lib,
  pkgs,
  sysPlasma5,
  ...
}: {
  imports = [
    ./applications.nix
    ./firefox
    ./hyprland
    ./keepassxc
  ];

  options.tgap.home.desktop.terminal = let
    inherit (lib) mkOption types;
  in
    mkOption {
      type = types.enum ["kitty" null];
      default = "kitty";
      description = "The terminal emulator program to install.";
    };

  config = let
    cfg = config.tgap.home.desktop;
    inherit (lib) mkIf;
  in
    mkIf (sysPlasma5 && cfg.terminal == "kitty") {
      programs.kitty = {
        enable = true;

        extraConfig = ''
          font_features FiraCodeNF-Reg +cv16 +cv18 +cv25 +cv26 +cv28 +cv29 +cv30 +cv31 +cv32 +onum +ss02 +ss03 +ss05 +ss06 +ss07 +ss08 +ss09 +zero
          font_features FiraCodeNF-SemBd +cv16 +cv18 +cv25 +cv26 +cv28 +cv29 +cv30 +cv31 +cv32 +onum +ss02 +ss03 +ss05 +ss06 +ss07 +ss08 +ss09 +zero

          font_features CaskaydiaCoveNF-SemiLightItalic +calt +ss01
          font_features CaskaydiaCoveNF-SemiBoldItalic +calt +ss01
        '';
        settings = {
          # Fonts
          "font_family" = "FiraCode Nerd Font";
          "bold_font" = "FiraCode Nerd Font SemBd";
          "italic_font" = "CaskaydiaCove NF SemiLight Italic";
          "bold_italic_font" = "CaskaydiaCove NF SemiBold Italic";

          "font_size" = "11.75";
          "disable_ligatures" = "cursor";

          # Cursor customization
          "cursor" = "none";
          "cursor_text_color" = "background";

          # Mouse
          "url_color" = "#387068";

          # Performance tuning
          "sync_to_monitor" = false;

          # Terminal bell
          "enable_audio_bell" = false;

          # Window layout
          "enabled_layouts" = "splits, grid, stack";
          "window_padding_width" = "0 2";
          "active_border_color" = "#2e7de9";
          "inactive_border_color" = "#c4c8da";

          # Tab bar
          "active_tab_foreground" = "#e9e9ec";
          "active_tab_background" = "#2e7de9";
          "inactive_tab_background" = "#c4c8da";
          "inactive_tab_foreground" = "#8990b3";
          "tab_bar_background" = "#e9e9ed";

          # Color scheme (Tokyo Night Day)
          "foreground" = "#3760bf";
          "background" = "#e1e2e7";
          "selection_foreground" = "#3760bf";
          "selection_background" = "#99a7df";
          # black
          "color0" = "#e9e9ed";
          "color8" = "#a1a6c5";
          # red
          "color1" = "#f52a65";
          "color9" = "#f52a65";
          # green
          "color2" = "#587539";
          "color10" = "#587539";
          # yellow
          "color3" = "#8c6c3e";
          "color11" = "#8c6c3e";
          # blue
          "color4" = "#2e7de9";
          "color12" = "#2e7de9";
          # magenta
          "color5" = "#9854f1";
          "color13" = "#9854f1";
          # cyan
          "color6" = "#007197";
          "color14" = "#007197";
          # white
          "color7" = "#6172b0";
          "color15" = "#3760bf";
          # extended
          "color16" = "#b15c00";
          "color17" = "#c64343";
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
    };
}
