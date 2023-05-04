{
  lib,
  pkgs,
  sysQmk,
  ...
}: {
  imports = [../common];

  tgap.user.programs.jupyter.enable = true;

  home.packages = lib.optionals sysQmk (with pkgs; [
    via
  ]);
}
