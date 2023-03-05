{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./neovim
  ];

  options.tgap.programs = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "Whether or not to enable common system-wide programs.";

    fd.enable = mkEnableOption "Whether to enable fd, an alternative to find.";

    glow.enable = mkEnableOption "Whether to enable glow, a CLI markdown renderer.";

    ripgrep.enable = mkEnableOption "Whether to enable ripgrep, an alternative to grep.";

    qmk.enable = mkEnableOption "Whether or not enable qmk and related udev packages.";

    virtualization.enable = mkEnableOption "Whether or not to enable Docker and VirtualBox.";

    extraPackages = mkOption {
      description = "Extra base application packages to install.";
      type = types.listOf types.package;
      default = [];
    };
  };

  config = let
    cfg = config.tgap.programs;
    inherit (lib) mkIf mkMerge optionals;
  in
    mkIf cfg.enable (mkMerge [
      {
        # List packages installed in system profile.
        environment.systemPackages =
          [
            # Hardware
            pkgs.gptfdisk
            pkgs.ntfs3g

            # Programs
            pkgs.busybox
            pkgs.git
            pkgs.jq
            pkgs.p7zip
            pkgs.ranger
            pkgs.unrar
            pkgs.unzip
            pkgs.tmux
            pkgs.wget
            pkgs.zip
          ]
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
          )
          ++ cfg.extraPackages;

        services = {
          openssh.enable = true;
          udev.packages = optionals cfg.qmk.enable [pkgs.qmk-udev-rules];
        };
      }
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
