{
  config,
  lib,
  pkgs,
  sysPlasma5,
  ...
}: {
  options.tgap.user.desktop = let
    inherit (lib) mkEnableOption;
  in {
    applications.enable = mkEnableOption "Whether or not to enable common desktop apps.";

    gaming.enable = mkEnableOption "Whether or not to enable gaming-related apps.";
  };

  config = let
    cfg = config.tgap.user.desktop;
    inherit (lib) mkIf mkMerge;
  in
    mkMerge [
      (mkIf (sysPlasma5 && cfg.applications.enable) {
        programs = {
          mpv = {
            enable = true;
            config = {
              profile = "gpu-hq";
              vo = "gpu";
              hwdec = "auto-safe";
              ytdl-format = "ytdl-format=bestvideo[height<=?1920][fps<=?60]+bestaudio/best";
            };
          };

          zathura = {
            enable = true;
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

        home.packages = with pkgs; [
          gimp
          keepassxc
          libreoffice-fresh
          nextcloud-client
          speedcrunch
          tor-browser-bundle-bin
          zoom-us
        ];
      })

      (mkIf (sysPlasma5 && cfg.gaming.enable) {
        home.packages = with pkgs; [
          gamemode
          lutris
          mangohud
          winetricks
          wineWowPackages.stagingFull
        ];
      })
    ];
}
