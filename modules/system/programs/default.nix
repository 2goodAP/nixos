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
    enable = mkEnableOption "Whether or not to enable common system-wide programs.";

    defaultShell = mkOption {
      description = "The default shell assigned to user accounts.";
      type = types.enum ["bash" "fish"];
      default = "fish";
    };

    fd.enable = mkEnableOption "Whether to enable fd, an alternative to find.";

    glow.enable = mkEnableOption "Whether to enable glow, a CLI markdown renderer.";

    ripgrep.enable = mkEnableOption "Whether to enable ripgrep, an alternative to grep.";

    qmk.enable = mkEnableOption "Whether or not enable qmk and related udev packages.";

    virtualization.enable = mkEnableOption "Whether or not to enable Docker and VirtualBox.";
  };

  config = let
    cfg = config.tgap.system.programs;
    inherit (lib) mkIf mkMerge optionals;
  in
    mkIf cfg.enable (mkMerge [
      {
        # List packages installed in system profile.
        environment.systemPackages =
          (with pkgs; [
            # Hardware
            gptfdisk
            ntfs3g

            # Programs
            busybox
            jq
            p7zip
            ranger
            unrar
            unzip
            tmux
            wget
            zip
          ])
          ++ (
            optionals cfg.fd.enable [pkgs.fd]
          )
          ++ (
            optionals cfg.glow.enable [pkgs.glow]
          )
          ++ (
            optionals cfg.ripgrep.enable [pkgs.ripgrep]
          )
          ++ (
            optionals cfg.qmk.enable [pkgs.qmk]
          );

        programs.git = {
          enable = true;
          lfs.enable = true;
          config = {
            init.defaultBranch = "main";
            pull.rebase = false;
            push.autoSetupRemote = true;
          };
        };

        services = {
          openssh.enable = true;
          udev.packages = optionals cfg.qmk.enable [pkgs.qmk-udev-rules];
        };
      }

      (mkIf (cfg.defaultShell == "fish") {
        programs.fish.enable = true;
        users.defaultUserShell = pkgs.fish;

        environment.systemPackages = with pkgs; [
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
      })

      (mkIf cfg.virtualization.enable {
        virtualisation = {
          docker = {
            enable = true;
            enableOnBoot = false;
            enableNvidia = builtins.elem "nvidia" config.services.xserver.videoDrivers;
            storageDriver = "overlay2";
            rootless.enable = true;
          };

          virtualbox = {
            guest.enable = true;
            host.enable = true;
          };
        };
      })
    ]);
}