{
  lib,
  osConfig,
  pkgs,
  ...
}: {
  imports = [../common];

  tgap.home.programs.jupyter.enable = true;
  home.packages = lib.optionals osConfig.tgap.system.programs.qmk.enable [pkgs.via];
}
