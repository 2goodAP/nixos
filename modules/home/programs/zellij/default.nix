{
  config,
  lib,
  osConfig,
  ...
}: let
  cfg = config.tgap.home.programs;
  osCfg = osConfig.tgap.system.programs;
  inherit (lib) getExe mkIf optionalString;
in
  mkIf cfg.enable {
    programs.zellij = {
      enable = true;

      themes.rose-pine-dawn = ''
        themes {
        	rose-pine-dawn {
        		bg "#dfdad9"
        		fg "#575279"
        		red "#b4637a"
        		green "#286983"
        		blue "#56949f"
        		yellow "#ea9d34"
        		magenta "#907aa9"
        		orange "#fe640b"
        		cyan "#d7827e"
        		black "#f2e9e1"
        		white "#575279"
        	}
        }
      '';
    };

    xdg.configFile."zellij/config.kdl".text = ''
      ${builtins.readFile ./zellij-config.kdl}

      simplified_ui true
      theme "rose-pine-dawn"
      ${optionalString (osCfg.defaultShell == "nushell") ''
        default_shell "${getExe config.programs.nushell.package}"
      ''}
    '';
  }
