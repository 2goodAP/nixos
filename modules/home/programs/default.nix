{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Whether or not to install common base applications.";

    jupyter.enable = mkEnableOption "Whether or not to enable jupyter user-settings.";
  };

  config = let
    cfg = config.tgap.home.programs;
    inherit (lib) mkIf mkMerge;
  in
    mkIf cfg.enable (mkMerge [
      {
        programs.beets = {
          enable = true;
          package = pkgs.beets-unstable;

          settings = {
            # Path to the music directory and the music library
            directory = "~/Music";
            library = "~/.local/share/beets/beets-music-library.db";

            # Move the music files instead of copying to save space
            import = {
              move = "yes";
            };

            # Plugins
            plugins = "chroma edit fetchart fromfilename zero";

            # Settings for the 'zero' plugin
            zero = {
              fields = "comments images day month";
              # Regexp to identify comments
              comments = "[EAC, LAME, from.+collection, 'ripped by']";
              update_database = true;
            };
          };
        };

        home.packages = with pkgs; [
          musikcube
          transmission
        ];

        home.file.musikcube-settings = {
          source = ./musikcube;
          target = ".config/musikcube";
          recursive = true;
        };
      }

      (mkIf cfg.jupyter.enable {
        home.file.jupyter-settings = {
          source = ./jupyter;
          target = ".jupyter/lab/user-settings";
          recursive = true;
        };
      })
    ]);
}
