{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  options.tgap.home.programs = let
    inherit (lib) mkOption types;
  in {
    nushellPlugins = mkOption {
      type = types.listOf types.package;
      default = with pkgs.nushellPlugins; [formats gstat polars query];
      description = "The nushell plugins to install alongside nushell.";
    };
  };

  config = let
    cfg = config.tgap.home.programs;
    nushellDefault = osConfig.tgap.system.programs.defaultShell == "nushell";
    inherit (lib) concatMapStringsSep getExe getExe' mkIf;

    plugin-msgpackz =
      pkgs.runCommand "plugin.msgpackz" {
        buildInputs = [pkgs.nushell];
      } ''
        nu --plugin-config $out -c '${concatMapStringsSep "\n"
          (p: "plugin add `${getExe p}`")
          cfg.nushellPlugins}'
      '';
  in
    mkIf (cfg.enable && nushellDefault) {
      xdg.configFile."nushell/plugin.msgpackz".source = plugin-msgpackz;

      programs.nushell = let
        nu_scripts = "${pkgs.nu_scripts}/share/nu_scripts";
      in {
        enable = true;
        configFile.source = ./config.nu;
        envFile.source = ./env.nu;
        package = osConfig.users.defaultUserShell;

        environmentVariables = {
          BATPIPE = "color";
          EDITOR = "nvim";
          LESSOPEN =
            "|"
            + getExe' pkgs.bat-extras.batpipe ".batpipe-wrapped"
            + " %s";
          PAGER = "${config.programs.nushell.shellAliases.less}";
          VISUAL = "nvim";
        };

        extraConfig = ''
          # Theme
          source ${nu_scripts}/themes/nu-themes/rose-pine-dawn.nu

          # Background tasks with pueue
          use modules/background_task/task.nu

          # carapace-bin setup
          source ${config.xdg.cacheHome}/carapace/init.nu
        '';

        extraEnv =
          (
            if config.programs.starship.enable
            then ''
              $env.PROMPT_INDICATOR = {|| "" }
              $env.PROMPT_INDICATOR_VI_INSERT = {|| "I " }
              $env.PROMPT_INDICATOR_VI_NORMAL = {|| "N " }
            ''
            else ''
              $env.PROMPT_COMMAND = {|| create_left_prompt }
              $env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }
              $env.PROMPT_INDICATOR = {|| "> " }
              $env.PROMPT_INDICATOR_VI_INSERT = {|| "> " }
              $env.PROMPT_INDICATOR_VI_NORMAL = {|| "< " }
              $env.PROMPT_MULTILINE_INDICATOR = {|| "... " }
            ''
          )
          + ''
            # Update NU_LIB_DIRS to include nu_scripts
            $env.NU_LIB_DIRS = (
              $env.NU_LIB_DIRS? | default [] | prepend '${nu_scripts}'
            )

            # Set XDG_CONFIG_HOME to ~/.config
            $env.XDG_CONFIG_HOME = ($env.HOME | path join '.config')

            # Add some local dirs to PATH
            $env.PATH = (
              $env.PATH | split row (char esep)
              | append ($env.HOME | path join ".local" "bin")
              | uniq
            )

            # carapace-bin setup
            let carapace_cache = "${config.xdg.cacheHome}/carapace"
            if not ($carapace_cache | path exists) {
              mkdir $carapace_cache
            }
            $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
            ${getExe pkgs.carapace} _carapace nushell | save -f (
              [$carapace_cache, "init.nu"] | path join
            )
          '';

        shellAliases = {
          br = "broot";
          brl = "broot -dsp";
          brs = "broot -s";
          diff = "diff --color";
          la = "ls -a";
          less = "less -FRi";
          ll = "ls -l";
          lla = "ls -adl";
          sed = "sed -E";
        };
      };
    };
}
