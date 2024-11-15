{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ./neovim
    ./nushell
    ./applications.nix
  ];

  options.tgap.home.programs = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "core CLI applications";
  };

  config = let
    cfg = config.tgap.home.programs;
    nushellDefault = osConfig.tgap.system.programs.defaultShell == "nushell";
    inherit (lib) getExe mkIf recursiveUpdate;
  in
    mkIf cfg.enable {
      services.pueue.enable = true;

      home.packages = with pkgs; [
        carapace
        ripgrep-all
        tmuxPlugins.rose-pine
      ];

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

            # carapace-bin setup
            export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
            source <(${getExe pkgs.carapace} _carapace)
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
    };
}
