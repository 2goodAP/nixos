{
  lib,
  pkgs,
  sysQmk,
  ...
}: {
  imports = [../common];

  tgap.user = {
    desktop.nixosApplications.enable = true;
    programs.jupyter.enable = true;
  };

  home.packages = lib.optionals sysQmk (with pkgs; [
    via
  ]);
}
