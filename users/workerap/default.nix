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
    imports = [../common];

    home.packages = with pkgs; [
      insomnia
      openvpn
    ];

    tgap.home = {
      desktop.applications.extras.enable = true;

      programs.applications = {
        extras.enable = true;
        jupyter.enable = true;
      };
    };
  };
}
