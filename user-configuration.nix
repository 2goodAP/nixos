# User and group configurations for the various nixos profiles.

{ pkgs, ... }:

{
  users = {
    defaultUserShell = pkgs.zsh;


    users = let
      userPackages = with pkgs; [
        firefox
        thunderbird
        ungoogled-chromium

        gimp
        keepassxc
        libreoffice-fresh
        nextcloud-client
        speedcrunch
        transmission
        zathura
        zoom-us
      ];
    in {
      aashishp = {
        isNormalUser = true;
        extraGroups = [
          "audio"
          "cups"
          "disk"
          "docker"
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
