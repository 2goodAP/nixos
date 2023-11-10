{
  lib,
  pkgs,
  sysQmk,
  ...
}: {
  imports = [../common];

  tgap.home.programs.jupyter.enable = true;

  home.packages = lib.optionals sysQmk (with pkgs; [
    via
  ]);
}
