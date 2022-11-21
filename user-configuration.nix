# User and group configurations for the various nixos profiles.
{pkgs, ...}: {
  users = {
    defaultUserShell = pkgs.zsh;

    users = let
      basePackages = with pkgs; [
        android-file-transfer
        libimobiledevice
        ifuse

        firefox
        keepassxc
        libreoffice-fresh
        nextcloud-client
        speedcrunch
        transmission
        zathura
      ];
      userPackages = basePackages ++ (with pkgs; [
        gimp
        thunderbird
        ungoogled-chromium
        zoom-us
      ]);
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
        packages = userPackages ++ (with pkgs; [insomnia openvpn]);
        initialPassword = "NixOS-workerap.";
      };
      
      justagamer = {
        isNormalUser = true;
        extraGroups = [
          "audio"
          "disk"
          "networkmanager"
          "video"
          "wheel"
        ];
        packages = basePackages ++ (with pkgs; [lutris wineWowPackages.staging]);
        initialPassword = "NixOS-justagamer.";
      };
    };
  };
}
