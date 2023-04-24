{
  config,
  pkgs,
  sysStateVersion,
  ...
}: {
  imports = [
    ../common
    ./programs
  ];

  tgap.user.programs.jupyter.enable = true;

  home.packages = with pkgs; [
    insomnia
    openvpn
  ];
}
