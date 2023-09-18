{
  config,
  options,
  pkgs,
  sysPlasma5,
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
      shellInit = ''
        # Tide vi-mode prompt icon.
        set --global tide_character_icon '>'
        set --global tide_vi_mode_icon_insert '>'
        set --global tide_character_vi_icon_default '<'
        set --global tide_vi_mode_icon_default '<'
        set --global tide_character_vi_icon_replace 'R'
        set --global tide_vi_mode_icon_replace 'R'
        set --global tide_character_vi_icon_visual 'V'
        set --global tide_vi_mode_icon_visual 'V'

        # Extra config for `pyenv init -`.
        set -U fish_user_paths $HOME/.pyenv/bin $fish_user_paths
      '';
      interactiveShellInit = ''
        fish_vi_key_bindings

        # >>> mamba initialize >>>
        # !! Contents within this block are managed by 'mamba init' !!
        set -gx MAMBA_EXE "$HOME/.local/bin/micromamba"
        set -gx MAMBA_ROOT_PREFIX "$HOME/.local/share/micromamba"
        $MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
        # <<< mamba initialize <<<
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

  services.gpg-agent = let
    setIf = cond: tVal: fVal:
      if cond
      then tVal
      else fVal;
  in {
    enable = true;
    pinentryFlavor =
      setIf sysPlasma5
      "qt"
      options.services.gpg-agent.pinentryFlavor.default;
  };

  home.packages = with pkgs; [
    # Hardware
    cryptsetup
    gptfdisk
    ntfs3g

    # Programs
    busybox
    htop
    fd
    glow
    jq
    p7zip
    ranger
    ripgrep
    unrar
    unzip
    wget
    zip

    # Fish Plugins
    fishPlugins.bass
    fishPlugins.colored-man-pages
    fishPlugins.done
    fishPlugins.fishtape_3
    fishPlugins.forgit
    fishPlugins.pisces
    fishPlugins.puffer
    fishPlugins.sponge
    fishPlugins.tide

    fishPlugins.fzf-fish
    fzf
    fishPlugins.grc
    grc
  ];
}
