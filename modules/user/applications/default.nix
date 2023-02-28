{
  config,
  lib,
  pkgs,
  ...
}: {
  options.machine.applications = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption {
      description = "Whether or not to enable common base applications.";
    };

    extraPackages = mkOption {
      description = "Extra base application packages to install.";
      type = types.listOf types.package;
      default = [];
    };
  };

  config = let
    cfg = config.machine.applications;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {};
}
