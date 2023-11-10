{pkgs, ...}: {
  imports = [../common];

  tgap.home.desktop.gaming = {
    enable = true;
    steam.enable = true;
  };

  home.packages = with pkgs; [
    rpcs3
    ryujinx
  ];
}
