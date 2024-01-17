let
  uname = builtins.baseNameOf ./.;
in {
  users.users."${uname}" = {
    isNormalUser = true;
    initialPassword = "NixOS-${uname}.";
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

  home-manager.users."${uname}" = {
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
