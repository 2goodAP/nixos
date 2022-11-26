# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{...}: {
  imports = [
    ./gui-configuration.nix
    ./hardware-configuration.nix
    ./package-configuration.nix
    ./service-configuration.nix
    ./system-configuration.nix
  ];
}
