{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ./neovim
    ./applications.nix
  ];

  options.tgap.home.programs = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "Whether or not to install core CLI applications.";

    nushellPlugins = mkOption {
      type = types.listOf types.package;
      default = with pkgs.nushellPlugins; [formats gstat query];
      description = "The nushell plugins to install alongside nushell.";
    };
  };

  config = let
    cfg = config.tgap.home.programs;
    nushellDefault = osConfig.tgap.system.programs.defaultShell == "nushell";
    inherit (lib) getExe getExe' mkIf mkMerge recursiveUpdate;
  in
    mkIf cfg.enable (mkMerge [
      {
        home.packages = [pkgs.tmuxPlugins.rose-pine];
        services.pueue.enable = true;

        programs = let
          rose-pine-tm-theme = pkgs.fetchFromGitHub {
            owner = "rose-pine";
            repo = "tm-theme";
            rev = "c4235f9a65fd180ac0f5e4396e3a86e21a0884ec";
            sha256 = "sha256-0u3pjxMn0Vzr97VudM+aY7ouXD8dRucsnhigaiCNGME=";
            sparseCheckout = ["dist/themes"];
          };
          tokyonight = pkgs.fetchFromGitHub {
            owner = "folke";
            repo = "tokyonight.nvim";
            rev = "e58f652cccd0baf337f23d2de0d6cd221c3b685b";
            sha256 = "sha256-DkEKB/FQVEYC6MWc1ZxOFIWgHWcGByiFfHamZFVEyVY=";
            sparseCheckout = ["extras/lazygit" "extras/tmux" "extras/yazi"];
          };
        in {
          atuin.enable = true;
          carapace.enable = true;
          fd.enable = true;
          jq.enable = true;
          ripgrep.enable = true;
          zoxide.enable = true;

          bat = {
            enable = true;
            config = {
              style = "changes,header-filename,header-filesize,numbers,rule,snip";
              theme = "RosePineDawn";
              map-syntax = [
                "*.config:INI"
                "*.jenkinsfile:Groovy"
                "*.props:Java Properties"
              ];
            };
            extraPackages = with pkgs.bat-extras; [
              batgrep
              batman
              batwatch
            ];
            themes.RosePineDawn = {
              src = rose-pine-tm-theme;
              file = "dist/themes/rose-pine-dawn.tmTheme";
            };
          };

          bash = {
            enable = true;
            historyControl = ["ignorespace"];

            initExtra = ''
              set -o vi
              bind '"\C-l": clear-screen'

              # batpipe init
              eval "$(${getExe pkgs.bat-extras.batpipe})"

              # yq completions
              source <(${getExe pkgs.yq-go} shell-completion bash)
            '';

            profileExtra = ''
              # Set preferred editor for local and remote sessions
              if [[ -n "$SSH_CONNECTION" ]]; then
                export EDITOR='vim'
                export VISUAL='vim'
              else
                export EDITOR='nvim'
                export VISUAL='nvim'
              fi
            '';

            shellAliases = {
              br = "broot";
              brl = "broot -dsp";
              brs = "broot -s";
              diff = "diff --color";
              egrep = "egrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
              grep = "grep -E --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
              la = "ls -a";
              less = "less -FRi";
              ll = "ls -lFh";
              lla = "ls -laFh";
              sed = "sed -E";
            };

            sessionVariables = {
              PAGER = "${config.programs.bash.shellAliases.less}";
              PATH = "$PATH:$HOME/.local/bin";
              XDG_CONFIG_HOME = "$HOME/.config";
            };
          };

          broot = {
            enable = true;
            settings.modal = true;
          };

          btop = {
            enable = true;
            settings.color_theme = "solarized_light";
          };

          lazygit = let
            configJSON = pkgs.runCommand "lazygit-config.json" {
              nativeBuildInputs = [pkgs.yq-go];
            } "yq -o json '.' ${tokyonight}/extras/lazygit/tokyonight_day.yml > $out";
          in {
            enable = true;
            settings = lib.importJSON configJSON;
          };

          starship = let
            presets = ["plain-text-symbols" "no-empty-icons"];
            presetsTOML =
              pkgs.runCommand "starship-presets.toml" {
                nativeBuildInputs = with pkgs; [coreutils yq];
              } ''
                tomlq -s -t 'reduce .[] as $item ({}; . * $item)' ${
                  lib.concatStringsSep " " (
                    map (f:
                      "${config.programs.starship.package}"
                      + "/share/starship/presets/${f}.toml")
                    presets
                  )
                } > $out
              '';
          in {
            enable = true;
            settings = recursiveUpdate (lib.importTOML presetsTOML) {
              add_newline = false;
            };
          };

          tmux = {
            enable = true;
            clock24 = true;
            customPaneNavigationAndResize = true;
            escapeTime = 10;
            keyMode = "vi";
            mouse = true;
            newSession = true;
            terminal = "screen-256color";
            extraConfig = ''
              set-option -g focus-events on
              set -g @plugin 'rose-pine/tmux'
              set -g @rose_pine_variant 'dawn'
            '';
          };

          yazi = {
            enable = true;
            enableBashIntegration = true;
            enableNushellIntegration = nushellDefault;
            theme = recursiveUpdate (
              lib.importTOML "${tokyonight}/extras/yazi/tokyonight_day.toml"
            ) {manager.highlight = "${tokyonight}/extras/yazi/tokyonight_day.tmTheme";};
          };
        };
      }

      (let
        inherit (lib) concatMapStringsSep;
        pluginMsgPackz =
          pkgs.runCommand "plugin.msgpackz" {
            buildInputs = [pkgs.nushell];
          } ''
            nu --plugin-config $out -c '${concatMapStringsSep "\n"
              (p: "plugin add `${getExe p}`")
              cfg.nushellPlugins}'
          '';
      in
        mkIf nushellDefault {
          xdg.configFile."nushell/plugin.msgpackz".source = pluginMsgPackz;

          programs.nushell = {
            enable = true;
            configFile.source = ./nushell/config.nu;
            envFile.source = ./nushell/env.nu;
            package = osConfig.users.defaultUserShell;

            environmentVariables =
              {
                BATPIPE = "color";
                EDITOR = "nvim";
                LESSOPEN =
                  "'|"
                  + getExe' pkgs.bat-extras.batpipe ".batpipe-wrapped"
                  + " %s'";
                NU_LIB_DIRS = "['${pkgs.nu_scripts}/share/nu_scripts']";
                PAGER = "'${config.programs.nushell.shellAliases.less}'";
                VISUAL = "nvim";
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
              use themes/nu-themes/rose-pine-dawn.nu
              $env.config.color_config = (rose-pine-dawn)

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
        })
    ]);
}
