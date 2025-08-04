{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./neovim
    ./nushell
    ./zellij
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
        rose-pine-tmTheme = pkgs.fetchFromGitHub {
          owner = "rose-pine";
          repo = "tm-theme";
          rev = "c4cab0c431f55a3c4f9897407b7bdad363bbb862";
          sha256 = "sha256-CMcEe45uulUb7vngg0MX09Isf9bIsC7Ag7m0Z8064FM=";
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
            src = rose-pine-tmTheme;
            file = "dist/themes/rose-pine-dawn.tmTheme";
          };
        };

        bash = {
          enable = true;
          historyControl = ["ignorespace"];

          initExtra = ''
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
          in
            optionalString cfg.neovim.enable ''
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
            egre = "egrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
            gre = "grep -E --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
            la = "ls -a";
            less = "less -FRi";
            ll = "ls -lFh";
            lla = "ls -laFh";
            se = "sed -E";
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

        readline = {
          enable = true;
          bindings."\\C-l" = "clear-screen";
          variables.editing-mode = "vi";
        };

        skim = {
          enable = true;
          defaultCommand =
            getExe config.programs.ripgrep.package
            + " --smart-case --pretty --engine=auto '{}'";
          changeDirWidgetCommand =
            getExe config.programs.fd.package
            + " --type=d --color=always";
          fileWidgetCommand =
            getExe config.programs.fd.package
            + " --type=f --color=always";

          defaultOptions = [
            "--ansi"
            ("--color=current:#575279,current_bg:#dfdad9,current_match:#faf4ed,"
              + "current_match_bg:#ea9d34,matched:#575279,matched_bg:#f7e3c8,"
              + "spinner:#286983,info:#d7827e,prompt:#907aa9,cursor:#286983,"
              + "selected:#cecacd,header:#b4637a,border:#797593")
          ];
          changeDirWidgetOptions = ["--preview '${getExe pkgs.tree} -C {} | head -200'"];
          fileWidgetOptions = ["--preview '${getExe config.programs.bat.package} {}'"];
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
            set -g allow-passthrough on
            set -g @plugin 'rose-pine/tmux'
            set -g @rose_pine_variant 'dawn'
          '';
        };

        yazi = {
          enable = true;
          theme = recursiveUpdate (lib.importTOML ./yazi/rose-pine-dawn.toml) {
            mgr.highlight = "${rose-pine-tmTheme}/dist/themes/rose-pine-dawn.tmTheme";
          };
        };
      };
    };
}
