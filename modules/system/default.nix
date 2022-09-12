{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./boot.nix
    ./laptop.nix
    ./network.nix
    ./programs.nix
  ];
}
