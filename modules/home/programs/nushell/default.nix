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

        environmentVariables =
          {
            BATPIPE = "'color'";
            EDITOR = "'nvim'";
            LESSOPEN =
              "'|"
              + getExe' pkgs.bat-extras.batpipe ".batpipe-wrapped"
              + " %s'";
            NU_LIB_DIRS = "['${nu_scripts}']";
            PAGER = "'${config.programs.nushell.shellAliases.less}'";
            VISUAL = "'nvim'";
            XDG_CONFIG_HOME = "($env.HOME | path join '.config')";
          }
          // (
            if config.programs.starship.enable
            then {
              PROMPT_INDICATOR = "{|| '' }";
              PROMPT_INDICATOR_VI_INSERT = "{|| 'I ' }";
              PROMPT_INDICATOR_VI_NORMAL = "{|| 'N ' }";
            }
            else {
              PROMPT_COMMAND = "{|| create_left_prompt }";
              PROMPT_COMMAND_RIGHT = "{|| create_right_prompt }";
              PROMPT_INDICATOR = "{|| '> ' }";
              PROMPT_INDICATOR_VI_INSERT = "{|| '> ' }";
              PROMPT_INDICATOR_VI_NORMAL = "{|| '< ' }";
              PROMPT_MULTILINE_INDICATOR = "{|| '... ' }";
            }
          );

        extraConfig = ''
          # Theme
          source ${nu_scripts}/themes/nu-themes/rose-pine-dawn.nu

          # Background tasks with pueue
          use modules/background_task/task.nu
        '';

        extraEnv = ''
          # Add some local dirs to PATH
          $env.PATH = (
            $env.PATH | split row (char esep)
            | append ($env.HOME | path join ".local" "bin")
            | uniq
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
