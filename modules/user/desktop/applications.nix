{
  config,
  lib,
  pkgs,
  sysDesktop,
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
      (mkIf (sysDesktop && cfg.applications.enable) {
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

          firefox = {
            enable = true;
            # profiles = {
            #   default = {
            #     id = 0;
            #     name = "default";
            #     settings = {
            #     };
            #     search = {
            #       engines = {
            #       };
            #       order = [
            #       ];
            #       default = "";
            #       force = true;
            #     };
            #     extensions = [
            #     ];
            #     bookmarks = {
            #     };
            #     extraconfig = ''
            #     '';
            #   };
            #   alternate = {
            #     id = 1;
            #     name = "alternate ";
            #     settings = {
            #     };
            #     search = {
            #       engines = {
            #       };
            #       order = [
            #       ];
            #       default = "";
            #       force = true;
            #     };
            #     extensions = [
            #     ];
            #   };
            # };
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

        home.packages = with pkgs; [
          gimp
          keepassxc
          libreoffice-fresh
          nextcloud-client
          speedcrunch
          zoom-us
        ];
      })

      (mkIf (sysDesktop && cfg.gaming.enable) {
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
