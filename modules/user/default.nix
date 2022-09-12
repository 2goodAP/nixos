{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./applications
    ./desktop
  ];
}
