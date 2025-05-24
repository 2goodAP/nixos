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
    inherit (lib) concatStringsSep getExe mkIf mkMerge optionalString;
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
            package = pkgs.beets-unstable;

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

        services.fluidsynth = {
          enable = true;
          soundFont = "${pkgs.soundfont-generaluser}/share/soundfonts/GeneralUser-GS.sf2";
          soundService = "pipewire-pulse";
          extraOptions = [
            "--sample-rate 48000"
            "--audio-bufcount 2"
            "--audio-bufsize 128"
          ];
        };

        home.packages = let
          fluidsynth-with-soundfont = pkgs.fluidsynth.overrideAttrs (oldAttrs: {
            postInstall =
              (oldAttrs.postInstall or "")
              + optionalString pkgs.stdenv.hostPlatform.isLinux ''
                mkdir -p $out/share/soundfonts
                ln -s ${config.services.fluidsynth.soundFont} \
                  $out/share/soundfonts/default.sf2
              '';
          });
        in
          with pkgs; [
            (symlinkJoin {
              name = "fluidsynth";
              buildInputs = [makeWrapper];
              paths = [
                fluidsynth-with-soundfont
                fluidsynth.dev
                fluidsynth.man
                soundfont-generaluser
              ];
              postBuild = ''
                wrapProgram $out/bin/fluidsynth --add-flags \
                  "-a pulseaudio ${concatStringsSep " "
                  config.services.fluidsynth.extraOptions}"
              '';
            })
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
