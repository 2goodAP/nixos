{
  config,
  options,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ./kitty.nix
    ./neovim
  ];

  programs = {
    bash = {
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

      bashrcExtra = ''
        # Increasing history size
        export HISTSIZE=1000

        # Set the XDG_CONFIG_HOME
        export XDG_CONFIG_HOME=$HOME/.config

        # Preferred editor for local and remote sessions
        if [[ -n $SSH_CONNECTION ]]; then
          export EDITOR='vim'
        else
          export EDITOR='nvim'
        fi

        # Using neovim as the default shell editor
        export VISUAL='nvim'
      '';

      initExtra = ''
        # Initialize prompt
        parse_git_branch() {
             git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
        }
        export PS1="\u@\h \w \$(parse_git_branch)\n\$ "

        # Enable vi-mode
        set -o vi

        # Clear screen on Ctrl-l
        bind '"\C-l": clear-screen'
      '';
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        fish_vi_key_bindings

        # Zoxide shell init
        zoxide init fish | source

        # >>> mamba initialize >>>
        # !! Contents within this block are managed by 'mamba init' !!
        set -gx MAMBA_EXE "$HOME/.local/bin/micromamba"
        set -gx MAMBA_ROOT_PREFIX "$HOME/.local/share/micromamba"
        $MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
        # <<< mamba initialize <<<
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

        # Extra Config for `pyenv init -`
        set -U fish_user_paths $HOME/.pyenv/bin $fish_user_paths
      '';
    };

    git = {
      enable = true;
      lfs.enable = true;
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        pull = {
          rebase = false;
        };
        push = {
          autoSetupRemote = true;
        };
      };
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

  services.gpg-agent = {
    enable = true;
    extraConfig = "no-allow-external-cache";
    pinentryPackage =
      if (osConfig.tgap.system.desktop.manager == "plasma")
      then pkgs.pinentry-qt
      else pkgs.pinentry-gtk2;
  };

  home.packages = let
    nixgl = pkgs.nixgl.override {
      nvidiaVersion = "550.78";
      nvidiaHash = "34070434527ec9d575483e7f11ca078e467e73f6defc54366ecfbdcfe4a3bf73";
    };
  in
    [
      nixgl.auto.nixGLDefault
      nixgl.auto.nixVulkanNvidia
      nixgl.nixGLIntel
      nixgl.nixGLNvidia
      nixgl.nixVulkanIntel
    ]
    ++ (with pkgs; [
      # Programs
      htop
      fd
      file
      fzf
      glow
      grc
      jq
      lazygit
      p7zip
      psutils
      pzip
      ranger
      ripgrep
      unrar-free
      util-linux
      wget
      zoxide

      # Fish Plugins
      fishPlugins.autopair
      fishPlugins.bass
      fishPlugins.colored-man-pages
      fishPlugins.done
      fishPlugins.fishtape_3
      fishPlugins.puffer
      fishPlugins.sponge
      fishPlugins.tide
      fishPlugins.fzf-fish
      fishPlugins.grc
    ]);
}
