{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.machine.applications;
  inherit (lib) mkIf mkEnableOption mkOption types;
in {
  options.machine.applications = {
    enable = mkEnableOption {
      description = "Whether or not to enable common base applications.";
    };

    extraPackages = mkOption {
      description = "Extra base application packages to install.";
      type = types.listOf types.package;
      default = [];
    };
  };

  config = mkIf cfg.enable {};
}
