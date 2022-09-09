{ config, pkgs, lib, ... }:

{
  imports = [
    ./bootloader.nix
    ./network.nix
  ];
}
