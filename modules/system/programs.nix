{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.machine.programs;
  inherit (lib) mkIf mkEnableOption mkOption types;
in {
  options.machine.programs = {
    enable = mkEnableOption {
      description = "Whether or not to enable common system-wide programs.";
    };

    extraPackages = mkOption {
      description = "Extra base application packages to install.";
      type = types.listOf types.package;
      default = [];
    };
  };

  config = mkIf cfg.enable {
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
        pkgs.neovim
        pkgs.p7zip
        pkgs.ranger
        pkgs.unrar
        pkgs.unzip
        pkgs.tmux
        pkgs.wget
        pkgs.zip
      ]
      ++ cfg.extraPackages;
  };
}
