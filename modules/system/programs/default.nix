{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
	  ./neovim.nix
	];

  options.machine.programs = let
    inherit (lib) mkEnableOption mkOption types;
	in {
    enable = mkEnableOption "Whether or not to enable common system-wide programs.";
    fd.enable = mkEnableOption "Whether to enable fd, an alternative to find."

    glow.enable = mkEnableOpton "Whether to enable glow, a CLI markdown renderer.";

    ripgrep.enable = mkEnableOption "Whether to enable ripgrep, an alternative to grep."

    extraPackages = mkOption {
      description = "Extra base application packages to install.";
      type = types.listOf types.package;
      default = [];
    };
  };

  config = let
	  cfg = config.machine.programs;
		inherit (lib) mkIf;
	in mkIf cfg.enable {
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
      ] ++ (if cfg.fd.enable
        then [pkgs.fd]
        else []
      ) ++ (if cfg.glow.enable
        then [pkgs.glow]
        else []
      ) ++ (if cfg.ripgrep.enable
        then [pkgs.ripgrep]
        else []
      ) ++ cfg.extraPackages;
  };
}
