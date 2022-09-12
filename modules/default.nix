{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./system ./user];
}
