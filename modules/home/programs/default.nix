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
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Whether or not to install core CLI applications.";
  };

  config = let
    cfg = config.tgap.home.programs;
    nushellDefault = osConfig.tgap.system.programs.defaultShell == "nu";
    inherit (lib) getExe mkIf mkMerge recursiveUpdate;
  in
    mkIf cfg.enable (mkMerge [
      {
        home.packages = [pkgs.tmuxPlugins.rose-pine];

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
          fd.enable = true;
          jq.enable = true;
          ripgrep.enable = true;

          atuin = {
            enable = true;
            enableBashIntegration = true;
            enableNushellIntegration = nushellDefault;
          };

          bat = {
            enable = true;
            config = {
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

            shellAliases = {
              br = "broot";
              brs = "broot -s";
              brl = "broot -dsp";
              diff = "diff --color";
              egrep = "egrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
              grep = "grep -E --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
              less = "less -FRi";
              la = "ls -a";
              ll = "ls -lFh";
              lla = "ls -laFh";
              sed = "sed -E";
            };

            sessionVariables = {
              PATH = "$PATH:$HOME/.local/bin";
              HISTSIZE = 10000;
              XDG_CONFIG_HOME = "$HOME/.config";
              PAGER = "${config.programs.bash.shellAliases.less}";
            };

            profileExtra = ''
              # Preferred editor for local and remote sessions
              if [[ -n "$SSH_CONNECTION" ]]; then
                export EDITOR='vim'
                export VISUAL='vim'
              else
                export EDITOR='nvim'
                export VISUAL='nvim'
              fi
            '';
          };

          broot = {
            enable = true;
            enableBashIntegration = true;
            enableNushellIntegration = nushellDefault;
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
            enableBashIntegration = true;
            enableNushellIntegration = nushellDefault;
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

          zoxide = {
            enable = true;
            enableBashIntegration = true;
            enableNushellIntegration = nushellDefault;
          };
        };
      }

      (mkIf nushellDefault {
        programs.bash.initExtra = ''
          # Start nushell by default from bashInteractive
          exec ${getExe config.programs.nushell.package} -i \
            --plugins "[ \
              '${getExe pkgs.nushellPlugins.formats}', \
              '${getExe pkgs.nushellPlugins.gstat}', \
              '${getExe pkgs.nushellPlugins.query}', \
            ]"
        '';

        programs.nushell = {
          enable = true;
          envFile.source = ./nushell/env.nu;
          configFile.source = ./nushell/config.nu;

          environmentVariables =
            {
              PATH = "($env.PATH | split row (char esep) | append ~/.local/bin)";
              NU_LIB_DIRS = "[${pkgs.nu_scripts}/share/nu_scripts]";
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
            use `themes/nu-themes/rose-pine-dawn.nu`
            $env.config.color_config = (rose-pine-dawn)

            # Custom completions
            (ls `${pkgs.nu_scripts}/share/nu_scripts/custom-completions`
              | where ($'($it.name)' | path type) == "dir"
              | each {|d| $'($d.name)' | path basename
              | ['source `custom-completions', $'($in)', $'($in).nu`']
              | path join} | to text)
          '';

          shellAliases = {
            br = "broot";
            brs = "broot -s";
            brl = "broot -dsp";
            diff = "diff --color";
            less = "less -FRi";
            la = "ls -a";
            ll = "ls -l";
            lla = "ls -adl";
            sed = "sed -E";
          };
        };
      })
    ]);
}
