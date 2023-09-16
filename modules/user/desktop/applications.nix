{
  config,
  lib,
  pkgs,
  sysPlasma5,
  ...
}: {
  options.tgap.user.desktop = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    applications.enable = mkEnableOption "Whether or not to enable common desktop apps.";

    nixosApplications.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether or not to enable desktop apps for NixOS only.";
    };

    gaming.enable = mkEnableOption "Whether or not to enable gaming-related apps.";
  };

  config = let
    cfg = config.tgap.user.desktop;
    inherit (lib) mkIf mkMerge optionals;
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

        home.packages =
          (with pkgs; [
            gimp
            speedcrunch
            tor-browser-bundle-bin
            wev
          ])
          ++ optionals sysPlasma5 [pkgs.libreoffice-qt];
      })

      (mkIf (sysPlasma5 && cfg.nixosApplications.enable) {
        home.packages = with pkgs; [
          gparted
          nextcloud-client
          zoom-us
        ];
      })

      (mkIf (sysPlasma5 && cfg.gaming.enable) {
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

        home.packages = with pkgs; [
          gamemode
          gamescope
          lutris-free
          winetricks
          wineWowPackages.stagingFull
        ];
      })
    ];
}
