{
  lib,
  pkgs,
  sysQmk,
  ...
}: {
  imports = [../common.nix];

  tgap.user.programs.jupyter.enable = true;

  home.packages = lib.optionals sysQmk [
    pkgs.via
  ];
}
