{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  options.tgap.home.programs = let
    inherit (lib) mkEnableOption;
  in {
    applications = {
      enable = mkEnableOption "extra CLI applications";
      jupyter.enable = mkEnableOption "jupyter user-settings";
    };
  };

  config = let
    cfg = config.tgap.home.programs.applications;
    osCfg = osConfig.tgap.system.network;
    inherit (lib) mkIf mkMerge;
  in
    mkIf cfg.enable (mkMerge [
      {
        programs = {
          aria2 = {
            enable = true;
            settings = {
              enable-dht = true;
              enable-dht6 = true;
              listen-port = osCfg.allowedPorts.aria2;
              dht-listen-port = osCfg.allowedPorts.aria2;
            };
          };

          beets = {
            enable = true;
            package = pkgs.beets-unstable.override (olds: {
              extraPatches =
                [
                  (pkgs.fetchpatch {
                    # Issue: https://github.com/beetbox/beets/issues/5527
                    # PR: https://github.com/beetbox/beets/pull/5650
                    name = "fix-im-backend";
                    url = "https://github.com/beetbox/beets/commit/1f938674015ee71431fe9bd97c2214f58473efd2.patch";
                    hash = "sha256-koCYeiUhk1ifo6CptOSu3p7Nz0FFUeiuArTknM/tpVQ=";
                    excludes = [
                      "docs/changelog.rst"
                    ];
                  })
                ]
                ++ olds.extraPatches;
            });

            settings = {
              # Path to the music directory and the music library
              directory = "~/Music";
              library = "~/.local/share/beets/beets-music-library.db";

              # Move the music files instead of copying to save space
              import.move = true;

              # Plugins
              plugins =
                "chroma fromfilename acousticbrainz edit embedart fetchart"
                + " mbsync scrub zero thumbnails duplicates export bareasc"
                + " filefilter fuzzy ihate web";

              # Settings for the 'zero' plugin
              zero = {
                fields = "comments images day month";
                # Regexp to identify comments
                comments = ["EAC" "LAME" "from.+collection" "ripped by"];
                update_database = true;
              };
            };
          };

          yt-dlp = {
            enable = true;
            settings = {
              embed-thumbnail = true;
              downloader = "http,ftp:aria2c";
              downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
            };
          };
        };

        home.packages = with pkgs; [
          musikcube
          transmission_4
        ];

        xdg.configFile.musikcube-settings = {
          source = ./musikcube;
          target = "musikcube";
          recursive = true;
        };
      }

      (mkIf osConfig.hardware.bluetooth.enable {
        services.mpris-proxy.enable = true;
      })

      (mkIf cfg.jupyter.enable {
        home.file.jupyter-settings = {
          source = ./jupyter;
          target = ".jupyter";
          recursive = true;
        };
      })
    ]);
}
