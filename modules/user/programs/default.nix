{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.user.programs = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption {
      description = "Whether or not to enable common base applications.";
    };
  };

  config = let
    cfg = config.tgap.user.programs;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      home.packages = with pkgs; [
        transmission
      ];
    };
}
