# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports = [ ./hardware.nix ./service.nix ];


  # Set time zone.
  time.timeZone = "Asia/Kathmandu";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";


  console = {
    font = "Lat2-Terminus18";
    keyMap = "us";
    packages = [ pkgs.terminus_font ];
  };


  # Enable flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Allow un-free (propriatery) packages.
  nixpkgs.config.allowUnfree = true;


  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Hardware
    acpi
    gparted
    gptfdisk
    ntfs3g
    pamixer
    pulseaudio
    tlp

    # Programs
    busybox
    cmus
    conda
    docker-compose
    git
    jq
		(neovim.override { withNodeJs = true; })
    (python39.withPackages (pks: with pks; [ black mypy pylint pynvim ]))
    (python310.withPackages (pks: with pks; [ black mypy pylint pynvim ]))
    p7zip
    ranger
    unrar
    unzip
    tmux
    wget
    zip
  ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "22.05";
}
