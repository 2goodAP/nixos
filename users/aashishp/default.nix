{
  lib,
  pkgs,
  sysQmk,
  ...
}: {
  imports = [
    ../common.nix
  ];

  home.packages = lib.optionals sysQmk [
    pkgs.via
  ];
}
