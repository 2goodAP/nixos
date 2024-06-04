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
      type = types.enum ["bash" "fish" "nu"];
      default = "fish";
      description = "The default shell assigned to user accounts.";
    };
  };

  config = let
    cfg = config.tgap.system.programs;
    nvidia = builtins.elem "nvidia" config.services.xserver.videoDrivers;
    inherit (lib) getExe getExe' mkIf mkMerge optionals;
  in
    mkIf cfg.enable (mkMerge [
      {
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

      (mkIf (cfg.defaultShell == "fish") {
        users.defaultUserShell = pkgs.fish;

        programs.fish = {
          enable = true;

          interactiveShellInit = ''
            fish_add_path -aP "$HOME/.local/bin"
            fish_vi_key_bindings

            # Initialize Atuin.
            ${getExe pkgs.atuin} init fish | ${getExe pkgs.gnused} -Ee \
              's:([=\(])(atuin|(.*\s+)atuin)(\s+.*\)?):\1\3${getExe pkgs.atuin}\4:g' \
              | source
            ${getExe pkgs.atuin} gen-completions --shell fish | source

            # Initialize nix-your-shell.
            ${getExe pkgs.nix-your-shell} fish | ${getExe pkgs.gnused} -Ee \
              's:(\s+)nix-your-shell(\s+):\1${getExe pkgs.nix-your-shell}\2:g' \
              | source
          '';

          shellInit = ''
            # TokyoNight Day Theme
            ## Color Palette
            set -l foreground 3760bf
            set -l selection b6bfe2
            set -l comment 848cb5
            set -l red f52a65
            set -l orange b15c00
            set -l yellow 8c6c3e
            set -l green 587539
            set -l purple 7847bd
            set -l cyan 007197
            set -l pink 9854f1

            ## Syntax Highlighting Colors
            set -g fish_color_normal $foreground
            set -g fish_color_command $cyan
            set -g fish_color_keyword $pink
            set -g fish_color_quote $yellow
            set -g fish_color_redirection $foreground
            set -g fish_color_end $orange
            set -g fish_color_error $red
            set -g fish_color_param $purple
            set -g fish_color_comment $comment
            set -g fish_color_selection --background=$selection
            set -g fish_color_search_match --background=$selection
            set -g fish_color_operator $green
            set -g fish_color_escape $pink
            set -g fish_color_autosuggestion $comment

            ## Completion Pager Colors
            set -g fish_pager_color_progress $comment
            set -g fish_pager_color_prefix $cyan
            set -g fish_pager_color_completion $foreground
            set -g fish_pager_color_description $comment
            set -g fish_pager_color_selected_background --background=$selection

            # Tide vi-mode Prompt Icon
            set -g tide_character_icon '>'
            set -g tide_vi_mode_icon_insert '>'
            set -g tide_character_vi_icon_default '<'
            set -g tide_vi_mode_icon_default '<'
            set -g tide_character_vi_icon_replace 'R'
            set -g tide_vi_mode_icon_replace 'R'
            set -g tide_character_vi_icon_visual 'V'
            set -g tide_vi_mode_icon_visual 'V'
          '';
        };

        environment.systemPackages =
          [pkgs.fzf pkgs.grc]
          ++ (with pkgs.fishPlugins; [
            autopair
            bass
            colored-man-pages
            done
            fishtape_3
            puffer
            sponge
            tide
            fzf-fish
            grc
          ]);
      })

      (mkIf (cfg.defaultShell == "nu") {
        users.defaultUserShell = pkgs.bashInteractive;

        environment.systemPackages =
          (with pkgs; [
            nufmt
            nushellFull
            nu_scripts
          ])
          ++ (with pkgs.nushellPlugins; [
            formats
            gstat
            net
            query
          ]);

          programs.bash.interactiveShellInit = ''
            # Start nushell by default from bashInteractive.
            exec ${getExe' pkgs.nushellFull "nu"}
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
