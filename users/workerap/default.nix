let
  uname = baseNameOf ./.;
in {
  users.users."${uname}" = {
    isNormalUser = true;
    initialPassword = "NixOS-${uname}.";
    createHome = true;
    extraGroups = [
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
      ../common/programs.nix
      ../common/applications.nix
    ];

    tgap.home.programs.applications.jupyter.enable = true;

    home.packages = with pkgs; [
      insomnia
      openvpn
    ];
  };
}
