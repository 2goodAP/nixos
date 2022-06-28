# User and group configurations for the various nixos profiles.

{ pkgs, ... }:

{
  users = {
    groups = {
      nixos = {};
    };


    defaultUserShell = pkgs.zsh;


    users = let
      pkgsUnstable = import <nixos-unstable> {};

      userPackages = (with pkgs; [
        alacritty
        foot

        firefox
        thunderbird
        ungoogled-chromium

        gimp
        imv
        keepassxc
        libreoffice-qt
        mpv
        nextcloud-client
        speedcrunch
        transmission
        xorg.xeyes
        zathura
        zoom-us
      ]);

    in {
      aashishp = {
        isNormalUser = true;
        extraGroups = [
          "audio"
          "cups"
          "disk"
          "docker"
          "nixos"
          "networkmanager"
          "video"
          "wheel"
        ];
        packages = userPackages;
        useDefaultShell = true;
      };

      workerap = {
        isNormalUser = true;
        extraGroups = [
          "audio"
          "cups"
          "disk"
          "docker"
          "nixos"
          "networkmanager"
          "video"
          "wheel"
        ];
        packages = userPackages ++ (with pkgs; [ insomnia ]);
        useDefaultShell = true;
      };
    };
  };
}
