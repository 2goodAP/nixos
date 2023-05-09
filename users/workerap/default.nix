{pkgs, ...}: {
  imports = [../common];

  tgap.user = {
    desktop.nixosApplications.enable = true;
    programs.jupyter.enable = true;
  };

  home.packages = with pkgs; [
    insomnia
    openvpn
  ];
}
