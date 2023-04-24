{
  config,
  lib,
  pkgs,
  sysPlasma5,
  ...
}: {
  config = let
    cfg = config.tgap.user.desktop;
    inherit (lib) mkIf;
  in
    mkIf (sysPlasma5 && cfg.applications.enable) {
      home = {
        packages = [pkgs.keepassxc];

        file.keepassxc-ini = {
          source = ./keepassxc.ini;
          target = ".config/keepassxc/keepassxc.ini";
          recursive = true;
        };
      };
    };
}
