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
      enable = mkEnableOption "other useful CLI applications";
      extras.enable =
        mkEnableOption "non-essential but nice-to-have CLI applications";
      jupyter.enable = mkEnableOption "jupyter user-settings";
    };
  };

  config = let
    cfg = config.tgap.home.programs.applications;
    osCfg = osConfig.tgap.system.network;
    inherit (lib) concatStringsSep mkIf mkMerge optionalString;
  in
    mkIf cfg.enable (mkMerge [
      {
        xdg.configFile.musikcube-settings = {
          source = ./musikcube;
          target = "musikcube";
          recursive = true;
        };

        home.packages = with pkgs; [
          musikcube
          transmission_4
        ];

        programs.aria2 = {
          enable = true;
          settings = let
            ports = osCfg.allowedPortRanges.aria2;
          in rec {
            max-connection-per-server = 8;
            proxy-method = "tunnel";
            retry-wait = 10;
            split = max-connection-per-server;
            enable-dht6 = true;
            dht-listen-port = toString ports.from + "-" + toString ports.to;
            listen-port = dht-listen-port;
            max-upload-limit = "100K";
            rpc-listen-port = osCfg.allowedPorts.aria2;
          };
        };
      }

      (mkIf osConfig.hardware.bluetooth.enable {
        services.mpris-proxy.enable = true;
      })

      (mkIf cfg.extras.enable {
        programs = {
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
            ariang-allinone

            (symlinkJoin {
              name = "fluidsynth";
              buildInputs = [makeWrapper];
              paths = [fluidsynth-with-soundfont];
              postBuild = ''
                wrapProgram $out/bin/fluidsynth --add-flags \
                  "-a pulseaudio ${concatStringsSep " "
                  config.services.fluidsynth.extraOptions}"
              '';
            })
          ];

        xdg.dataFile = {
          "soundfonts/GeneralUser-GS.sf2".source =
            "${pkgs.soundfont-generaluser}/share"
            + "/soundfonts/GeneralUser-GS.sf2";
          "soundfonts/SalamanderGrandPiano.sf2".source =
            "${pkgs.soundfont-salamander-grand}/share"
            + "/soundfonts/SalamanderGrandPiano.sf2";
          "soundfonts/UprightPianoKW.sf2".source =
            "${pkgs.soundfont-upright-kw}/share"
            + "/soundfonts/UprightPianoKW.sf2";
        };
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
