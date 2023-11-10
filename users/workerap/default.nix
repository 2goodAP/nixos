{pkgs, ...}: {
  imports = [../common];

  tgap.home.programs.jupyter.enable = true;

  home.packages = with pkgs; [
    insomnia
    openvpn
  ];
}
