{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./neovim
  ];

  options.tgap.system.programs = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "Whether or not to install common system-wide programs.";
    androidTools.enable = mkEnableOption "Whether or not enable Android helper packages.";
    cms.enable = mkEnableOption "Whether to enable color management systems.";
    glow.enable = mkEnableOption "Whether to enable glow, a CLI markdown renderer.";
    iosTools.enable = mkEnableOption "Whether or not enable iOS helper packages.";
    qmk.enable = mkEnableOption "Whether or not enable qmk and related udev packages.";
    virtualisation.enable = mkEnableOption "Whether or not to enable Docker and VirtualBox.";

    defaultShell = mkOption {
      type = types.enum ["bash" "nu"];
      default = "nu";
      description = "The default shell assigned to user accounts.";
    };
  };

  config = let
    cfg = config.tgap.system.programs;
    nvidia = builtins.elem "nvidia" config.services.xserver.videoDrivers;
    inherit (lib) getExe mkIf mkMerge optionals;
  in
    mkIf cfg.enable (mkMerge [
      {
        users.defaultUserShell = pkgs.bashInteractive;

        # List packages installed in system profile.
        environment.systemPackages =
          [config.boot.kernelPackages.turbostat]
          ++ (with pkgs; [
            # Hardware
            exfatprogs
            gptfdisk
            ntfs3g
            parted
            s-tui

            # Programs
            broot
            btop
            fd
            file
            git-filter-repo
            jq
            lazygit
            p7zip
            pciutils
            psmisc
            pzip
            ripgrep
            unrar-free
            util-linux
            wget
            yq-go
          ])
          ++ (optionals cfg.androidTools.enable (with pkgs; [
            android-file-transfer
            android-tools
          ]))
          ++ (optionals cfg.glow.enable [pkgs.glow])
          ++ (optionals cfg.iosTools.enable (with pkgs; [
            ifuse
            libimobiledevice
          ]))
          ++ (optionals cfg.qmk.enable [pkgs.qmk]);

        programs = {
          gnupg.agent.enable = true;

          bash = {
            blesh.enable = true;

            interactiveShellInit = ''
              export PATH=$PATH:"$HOME/.local/bin"
              set -o vi
              bind '"\C-l": clear-screen'

              # yq completions
              source <(${getExe pkgs.yq-go} shell-completion bash)

              # Initialize Atuin.
              eval "$(${getExe pkgs.atuin} init bash | ${getExe pkgs.gnused} -Ee \
                's:(\$?\()(atuin|(.*\s+)atuin)(\s+.*\)):\1\3${getExe pkgs.atuin}\4:g')"
              eval "$(${getExe pkgs.atuin} gen-completions --shell bash)"
            '';

            shellAliases = {
              # Meta aliases
              "dotfiles" = "git --git-dir=$HOME/.dotfiles --work-tree=$HOME";

              # Program aliases
              "ll" = "ls -lFh";
              "la" = "ls -laFh";
              "diff" = "diff --color";
              "less" = "less -i";
              "grep" = "grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
              "egrep" = "egrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
              "sed" = "sed -E";
            };

            shellInit = ''
              # Increasing history size
              export HISTSIZE=1000

              # Set the XDG_CONFIG_HOME
              export XDG_CONFIG_HOME="$HOME/.config"

              # Preferred editor for local and remote sessions
              if [[ -n "$SSH_CONNECTION" ]]; then
                export EDITOR='vim'
              else
                export EDITOR='nvim'
              fi

              # Using neovim as the default shell editor
              export VISUAL='nvim'
            '';
          };

          git = {
            enable = true;
            lfs.enable = true;
            config = {
              init.defaultBranch = "main";
              pull.rebase = false;
              push.autoSetupRemote = true;
            };
          };

          starship = {
            enable = true;
            settings.add_newline = false;
            presets = [
              "plain-text-symbols"
              "no-empty-icons"
            ];
          };

          tmux = {
            enable = true;
            terminal = "screen-256color";
            newSession = true;
            keyMode = "vi";
            escapeTime = 10;
            extraConfig = ''
              set-option -g focus-events on
              set -g mouse on

              # TokyoNight colors for Tmux
              set -g mode-style "fg=#2e7de9,bg=#a8aecb"

              set -g message-style "fg=#2e7de9,bg=#a8aecb"
              set -g message-command-style "fg=#2e7de9,bg=#a8aecb"

              set -g pane-border-style "fg=#a8aecb"
              set -g pane-active-border-style "fg=#2e7de9"

              set -g status "on"
              set -g status-justify "left"

              set -g status-style "fg=#2e7de9,bg=#e9e9ec"

              set -g status-left-length "100"
              set -g status-right-length "100"

              set -g status-left-style NONE
              set -g status-right-style NONE

              set -g status-left "#[fg=#e9e9ed,bg=#2e7de9,bold] #S #[fg=#2e7de9,bg=#e9e9ec,nobold,nounderscore,noitalics]|>"
              set -g status-right "#[fg=#e9e9ec,bg=#e9e9ec,nobold,nounderscore,noitalics]<|#[fg=#2e7de9,bg=#e9e9ec] #{prefix_highlight} #[fg=#a8aecb,bg=#e9e9ec,nobold,nounderscore,noitalics]<|#[fg=#2e7de9,bg=#a8aecb] %Y-%m-%d < %I:%M %p #[fg=#2e7de9,bg=#a8aecb,nobold,nounderscore,noitalics]<|#[fg=#e9e9ed,bg=#2e7de9,bold] #h "

              setw -g window-status-activity-style "underscore,fg=#6172b0,bg=#e9e9ec"
              setw -g window-status-separator ""
              setw -g window-status-style "NONE,fg=#6172b0,bg=#e9e9ec"
              setw -g window-status-format "#[fg=#e9e9ec,bg=#e9e9ec,nobold,nounderscore,noitalics]|>#[default] #I > #W #F #[fg=#e9e9ec,bg=#e9e9ec,nobold,nounderscore,noitalics]|>"
              setw -g window-status-current-format "#[fg=#e9e9ec,bg=#a8aecb,nobold,nounderscore,noitalics]|>#[fg=#2e7de9,bg=#a8aecb,bold] #I > #W #F #[fg=#a8aecb,bg=#e9e9ec,nobold,nounderscore,noitalics]|>"

              # tmux-plugins/tmux-prefix-highlight support
              set -g @prefix_highlight_output_prefix "#[fg=#8c6c3e]#[bg=#e9e9ec]<|#[fg=#e9e9ec]#[bg=#8c6c3e]"
              set -g @prefix_highlight_output_suffix "<|"
            '';
          };
        };

        services = {
          atuin.enable = true;
          openssh.enable = true;
          udev.packages = optionals cfg.qmk.enable [pkgs.qmk-udev-rules];
        };
      }

      (mkIf (cfg.defaultShell == "nu") {
        environment.systemPackages = with pkgs; [nushellFull];

        programs.bash.interactiveShellInit = let
          atuinInit =
            pkgs.runCommand "atuin-init" {
              buildInputs = with pkgs; [atuin coreutils gnused];
            } ''
              export HOME="$PWD/home"
              mkdir -p $out $HOME

              atuin init nu | sed -Ee \
                's|([^:][{([:space:]])atuin(\s)|\1${getExe pkgs.atuin}\2|g' \
                > $out/init.nu
              atuin gen-completions --shell nushell --out-dir $out
            '';

          envNu = pkgs.writeText "env.nu" ''
            ${builtins.readFile ./nushell/env.nu}

            # Directories to search for scripts when calling source or use
            $env.NU_LIB_DIRS = [`${pkgs.nu_scripts}/share/nu_scripts`]
          '';

          configNu = pkgs.writeText "config.nu" ''
            ${builtins.readFile ./nushell/config.nu}

            # Theme
            use `themes/nu-themes/tokyo-day.nu`
            $env.config.color_config = (tokyo-day)

            # Custom completions
            (ls `${pkgs.nu_scripts}/share/nu_scripts/custom-completions`
              | where ($'($it.name)' | path type) == "dir"
              | each {|d| $'($d.name)' | path basename
              | ['source `custom-completions', $'($in)', $'($in).nu`']
              | path join} | to text)

            # Initialize Atuin
            source `${atuinInit}/init.nu`
            source `${atuinInit}/atuin.nu`
          '';
        in ''
          # Start nushell by default from bashInteractive
          exec ${getExe pkgs.nushellFull} -i \
            --env-config '${envNu}' \
            --config '${configNu}' \
            --plugins "[ \
              '${getExe pkgs.nushellPlugins.formats}', \
              '${getExe pkgs.nushellPlugins.gstat}', \
              '${getExe pkgs.nushellPlugins.query}', \
            ]"
        '';
      })

      (mkIf cfg.cms.enable {
        environment.systemPackages = optionals nvidia [pkgs.argyllcms];
        services.colord.enable = !nvidia;
      })

      (mkIf cfg.iosTools.enable {
        services.usbmuxd.enable = true;
      })

      (mkIf cfg.virtualisation.enable {
        virtualisation = {
          docker = {
            enable = true;
            enableOnBoot = false;
            enableNvidia = nvidia;
            storageDriver = "overlay2";
            rootless.enable = true;
          };

          virtualbox = {
            guest.enable = true;

            host = {
              enable = true;
              enableExtensionPack = true;
            };
          };
        };
      })
    ]);
}
