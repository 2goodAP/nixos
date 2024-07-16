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

  home-manager.users."${uname}" = {pkgs, ...}: {
    imports = [
      ../common/common.nix
      ../common/applications.nix
    ];

    tgap.home.programs.applications.jupyter.enable = true;

    home.packages = with pkgs; [
      insomnia
      openvpn
    ];
  };
}
