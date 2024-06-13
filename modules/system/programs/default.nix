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
    yazi = pkgs.yazi.override {
      settings.theme =
        recursiveUpdate
        (lib.importTOML ./yazi/tokyonight_day.toml) {
          manager.highlight = ./yazi/tokyonight_day.tmTheme;
        };
    };
    inherit (lib) getExe mkIf mkMerge optionals optionalString recursiveUpdate;
  in
    mkIf cfg.enable (mkMerge [
      {
        users.defaultUserShell = pkgs.bashInteractive;

        # List packages installed in system profile.
        environment.systemPackages =
          [config.boot.kernelPackages.turbostat yazi]
          ++ (with pkgs; [
            # Hardware
            exfatprogs
            gptfdisk
            ntfs3g
            parted
            s-tui

            # Programs
            bat
            broot
            btop
            delta
            fd
            file
            git-filter-repo
            git-subrepo
            jc
            jq
            p7zip
            pciutils
            psmisc
            pzip
            ripgrep
            unrar-free
            util-linux
            wget
            yq-go
            zoxide
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

              # Initialize zoxide
              eval "$(${getExe pkgs.zoxide} init bash)"

              ${optionalString config.programs.starship.enable ''
                # Starship completions
                eval "$(${getExe config.programs.starship.package} completions bash)"
              ''}

              ${optionalString config.services.atuin.enable ''
                # Initialize Atuin
                eval "$(${getExe pkgs.atuin} init bash | ${getExe pkgs.gnused} -Ee \
                  's:(\$?\()(atuin|(.*\s+)atuin)(\s+.*\)):\1\3${getExe pkgs.atuin}\4:g')"
                eval "$(${getExe pkgs.atuin} gen-completions --shell bash)"
              ''}

              # Change cwd when exiting yazi
              function ya() {
                local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
                ${getExe yazi} "$@" --cwd-file="$tmp"
                if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                  cd -- "$cwd"
                fi
                rm -f -- "$tmp"
              }
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

            shellInit = ''
              # Increasing history size
              export HISTSIZE=10000

              # Set the XDG_CONFIG_HOME
              export XDG_CONFIG_HOME="$HOME/.config"

              # Set default pager to work with rust programs
              export PAGER='${config.programs.bash.shellAliases.less}'

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
              core.pager = "${getExe pkgs.delta}";
              delta.navigate = true;
              diff.colorMoved = "default";
              init.defaultBranch = "main";
              interactive.diffFilter = "${getExe pkgs.delta} --color-only";
              merge.conflictstyle = "diff3";
              pull.rebase = false;
              push.autoSetupRemote = true;
            };
          };

          lazygit = let
            configJSON = pkgs.runCommand "lazygit-config.json" {
              nativeBuildInputs = [pkgs.yq-go];
            } "yq -o json '.' '${./lazygit/tokyonight_day.yml}' > $out";
          in {
            enable = true;
            settings = lib.importJSON configJSON;
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

              ${builtins.readFile ./tmux/tokyonight_day.tmux}
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
          nushellInit = let
            starCfg = config.programs.starship;
            starshipTOML =
              (pkgs.formats.toml {}).generate "starship.toml" starCfg.settings;
            presetFiles = lib.concatStringsSep " " (
              map (f: "${starCfg.package}/share/starship/presets/${f}.toml")
              starCfg.presets
            );
          in
            pkgs.runCommand "nushell-init" {
              nativeBuildInputs = with pkgs; [
                atuin
                coreutils
                gnused
                yq
                zoxide
              ];
            } ''
              export HOME="$PWD/home"
              mkdir -p $out $HOME

              # Starship
              mkdir $out/starship
              ${
                if starCfg.presets == []
                then "cat ${starshipTOML} > $out/starship/starship.toml"
                else ''
                  ${getExe starCfg.package} init nu > $out/starship/init.nu
                  tomlq -s -t 'reduce .[] as $item ({}; . * $item)' ${presetFiles} \
                    ${starshipTOML} > $out/starship/starship.toml
                ''
              }

              # Atuin
              mkdir $out/atuin
              atuin init nu | sed -Ee \
                's|([^:][{([:space:]])atuin(\s)|\1${getExe pkgs.atuin}\2|g' \
                > $out/atuin/init.nu
              atuin gen-completions --shell nushell --out-dir $out/atuin

              # Zoxide
              mkdir $out/zoxide
              zoxide init nushell > $out/zoxide/init.nu
            '';

          envNu = pkgs.writeText "env.nu" ''
            ${builtins.readFile ./nushell/env.nu}

            # Directories to search for scripts when calling source or use
            $env.NU_LIB_DIRS = [`${pkgs.nu_scripts}/share/nu_scripts`]

            ${
              if config.programs.starship.enable
              then ''
                # The prompt indicators are environmental variables that represent
                # the state of the prompt
                $env.PROMPT_INDICATOR = {|| "" }
                $env.PROMPT_INDICATOR_VI_INSERT = {|| "I " }
                $env.PROMPT_INDICATOR_VI_NORMAL = {|| "N " }
                $env.PROMPT_MULTILINE_INDICATOR = {|| "... " }
              ''
              else ''
                # Use nushell functions to define your right and left prompt
                $env.PROMPT_COMMAND = {|| create_left_prompt }
                # FIXME: This default is not implemented in rust code as of 2023-09-08.
                $env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

                # The prompt indicators are environmental variables that represent
                # the state of the prompt
                $env.PROMPT_INDICATOR = {|| "> " }
                $env.PROMPT_INDICATOR_VI_INSERT = {|| "> " }
                $env.PROMPT_INDICATOR_VI_NORMAL = {|| "< " }
                $env.PROMPT_MULTILINE_INDICATOR = {|| "... " }
              ''
            }
          '';

          configNu = pkgs.writeText "config.nu" ''
            ${builtins.readFile ./nushell/config.nu}

            # Aliases
            export alias br = broot
            export alias brs = broot -s
            export alias brl = broot -dsp
            export alias diff = diff --color
            export alias less = less -i
            export alias la = ls -a
            export alias ll = ls -l
            export alias lla = ls -adl
            export alias sed = sed -E

            # Theme
            use `themes/nu-themes/rose-pine-dawn.nu`
            $env.config.color_config = (rose-pine-dawn)

            # Custom completions
            (ls `${pkgs.nu_scripts}/share/nu_scripts/custom-completions`
              | where ($'($it.name)' | path type) == "dir"
              | each {|d| $'($d.name)' | path basename
              | ['source `custom-completions', $'($in)', $'($in).nu`']
              | path join} | to text)

            # Initialize Zoxide
            source `${nushellInit}/zoxide/init.nu`

            ${optionalString config.programs.starship.enable ''
              # Initialize Starship
              if ($'($env.HOME)/.config/starship.toml' | path exists | not $in) {
                $env.STARSHIP_CONFIG = `${nushellInit}/starship/starship.toml`
              }
              use `${nushellInit}/starship/init.nu`
            ''}

            ${optionalString config.services.atuin.enable ''
              # Initialize Atuin
              source `${nushellInit}/atuin/init.nu`
              source `${nushellInit}/atuin/atuin.nu`
            ''}

            # Change cwd when exiting yazi
            def --env ya [...args] {
              let tmp = (mktemp -t "yazi-cwd.XXXXXX")
              ${getExe yazi} ...$args --cwd-file $tmp
              let cwd = (open $tmp)
              if $cwd != "" and $cwd != $env.PWD {
                cd $cwd
              }
              rm -fp $tmp
            }
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
