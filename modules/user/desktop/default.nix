{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./applications.nix
    ./services.nix
    ./sway.nix
  ];
}
