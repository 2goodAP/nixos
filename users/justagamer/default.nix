{
  users.users.justagamer = {
    isNormalUser = true;
    initialPassword = "NixOS-justagamer.";
    createHome = true;
    extraGroups = [
      "audio"
      "disk"
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  home-manager.users.justagamer = {pkgs, ...}: {
    imports = [../common];

    tgap.home.desktop.steam.enable = true;

    home.packages = with pkgs; [
      rpcs3
      ryujinx
    ];
  };
}
