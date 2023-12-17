{
  users.users.workerap = {
    isNormalUser = true;
    initialPassword = "NixOS-workerap.";
    createHome = true;
    extraGroups = [
      "audio"
      "cups"
      "disk"
      "docker"
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  home-manager.users.workerap = {pkgs, ...}: {
    imports = [../common];

    tgap.home.programs.jupyter.enable = true;

    home.packages = with pkgs; [
      insomnia
      openvpn
    ];
  };
}
