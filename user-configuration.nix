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

        android-file-transfer
        libimobiledevice
        ifuse

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
      root = {
        isSystemUser = true;
        initialPassword = "NixOS-root.";
      };

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
        initialPassword = "NixOS-aashishp.";
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
        packages = userPackages ++ (with pkgs; [ insomnia openvpn ]);
        initialPassword = "NixOS-workerap.";
      };
    };
  };
}
