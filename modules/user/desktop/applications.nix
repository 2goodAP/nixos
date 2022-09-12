{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.machine.desktop;
  inherit (lib) mkIf mkEnableOption mkOption types;
in {
  options.machine.desktop.applications = {
    enable = mkEnableOption {
      description = "Whether or not to enable common desktop applications.";
    };

    extraPackages = mkOption {
      description = "Extra desktop application packages to install.";
      type = types.listOf types.package;
      default = [];
    };
  };

  config = mkIf (cfg.sway.enable && cfg.applications.enable) {
    programs = {
      chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;
        commandLineArgs = [
          # Hardware Acceleration
          "--ignore-gpu-blocklist"
          "--enable-gpu-rasterization"
          "--enable-zero-copy"
          # Native Wayland
          "--ozone-platform-hint=auto"
        ];
        extensions = [
          {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # uBlock Origin
          {id = "gcbommkclmclpchllfjekcdonpmejbdp";} # HTTPS Everywhere
          {id = "ldpochfccmkkmhdbclfhpagapcfdljkj";} # Decentraleyes
          {id = "pooaemmkohlphkekccfajnbcokjlbehk";} # Smart Clean
        ];
      };

      mpv = {
        enable = true;
        config = {
          profile = "gpu-hq";
          vo = "gpu";
          hwdec = "auto-safe";
          ytdl-format = "ytdl-format=bestvideo[height<=?1920][fps<=?60]+bestaudio/best";
        };
      };
    };

    home.packages = [
      pkgs.imv
      pkgs.gimp
      pkgs.firefox
      pkgs.keepassxc
      pkgs.libreoffice-fresh
      pkgs.nextcloud-client
      pkgs.speedcrunch
      pkgs.zathura
      pkgs.zoom-us
    ] ++ cfg.applications.extraPackages;
  };
}
