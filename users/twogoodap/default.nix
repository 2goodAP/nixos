{
  users.users.twogoodap = {
    isNormalUser = true;
    initialPassword = "NixOS-twogoodap.";
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

  home-manager.users.twogoodap = {
    lib,
    osConfig,
    pkgs,
    ...
  }: {
    imports = [../common];

    tgap.home.programs.jupyter.enable = true;
    home.packages = lib.optionals osConfig.tgap.system.programs.qmk.enable [pkgs.via];
  };
}
