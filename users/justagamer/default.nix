{pkgs, ...}: {
  imports = [../common];

  tgap.user.desktop.gaming.enable = true;

  home.packages = with pkgs; [
    rpcs3
    ryujinx
  ];
}
