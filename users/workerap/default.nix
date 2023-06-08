{pkgs, ...}: {
  imports = [../common];

  tgap.user.programs.jupyter.enable = true;

  home.packages = with pkgs; [
    insomnia
    openvpn
  ];
}
