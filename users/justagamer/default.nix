{pkgs, ...}: {
  imports = [../common];
  tgap.home.desktop.steam.enable = true;

  home.packages = with pkgs; [
    rpcs3
    ryujinx
  ];
}
