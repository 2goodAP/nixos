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
    deskCfg = config.tgap.home.desktop;
    inherit (lib) getExe mkIf recursiveUpdate optionalString;
  in
    mkIf cfg.enable {
      services.pueue.enable = true;

      home = {
        shell.enableBashIntegration = config.programs.bash.enable;

        packages = with pkgs; [
          carapace
          git-credential-oauth
          ripgrep-all
          tmuxPlugins.rose-pine
        ];
      };

      programs = let
        rose-pine-tm-theme = pkgs.fetchFromGitHub {
          owner = "rose-pine";
          repo = "tm-theme";
          rev = "c4235f9a65fd180ac0f5e4396e3a86e21a0884ec";
          sha256 = "sha256-0u3pjxMn0Vzr97VudM+aY7ouXD8dRucsnhigaiCNGME=";
          sparseCheckout = ["dist/themes"];
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

            # ble.sh
            # ------
            ## Set ESC timeout
            stty time 0
            bind 'set keyseq-timeout ${toString config.programs.tmux.escapeTime}'

            ## Set vi-mode cursor style
            ble-bind -m vi_nmap --cursor 2  # block
            ble-bind -m vi_imap --cursor 5  # blinking-bar
            ble-bind -m vi_omap --cursor 4  # underline
            ble-bind -m vi_xmap --cursor 2  # block
            ble-bind -m vi_cmap --cursor 0  # default

            # batpipe init
            eval "$(${getExe pkgs.bat-extras.batpipe})"

            # yq completions
            source <(${getExe pkgs.yq-go} shell-completion bash)

            # carapace-bin setup
            export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
            source <(${getExe pkgs.carapace} _carapace)
          '';

          profileExtra = let
            neovim = getExe config.programs.neovim.finalPackage;
          in ''
            # Set preferred editor for local and remote sessions
            if [[ -n "$SSH_CONNECTION" ]]; then
              export EDITOR='vim'
              export VISUAL='vim'
            else
              export EDITOR='${neovim}'
              export VISUAL='${neovim}'
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

        git = {
          enable = true;
          delta.enable = true;
          extraConfig = {
            init.defaultBranch = "main";
            pull.rebase = false;
            push.autoSetupRemote = true;
            credential.helper = [
              (optionalString deskCfg.applications.enable "${
                getExe pkgs.keepassxc
              } -vv --git-groups")
              "cache --timeout 21600  # six hours"
              (getExe pkgs.git-credential-oauth
                + optionalString (!deskCfg.applications.enable) " -device")
            ];
          };
          lfs = {
            enable = true;
            skipSmudge = true;
          };
          signing = {
            key = null;
            signByDefault = true;
          };
        };

        gpg = {
          enable = true;
          settings.default-new-key-algo = "ed25519/cert";
        };

        lazygit = let
          configJSON = pkgs.runCommand "lazygit-config.json" {
            nativeBuildInputs = [pkgs.yq-go];
          } "yq -o json '.' ${./lazygit/rose-pine-dawn.yml} > $out";
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
          escapeTime = 1;
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
          theme = recursiveUpdate (lib.importTOML ./yazi/rose-pine-dawn.toml) {
            mgr.highlight = "${rose-pine-tm-theme}/dist/themes/rose-pine-dawn.tmTheme";
          };
        };
      };
    };
}
