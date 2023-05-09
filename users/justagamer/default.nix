{pkgs, ...}: {
  imports = [../common];

  tgap.user.desktop = {
    nixosApplications.enable = true;
    gaming.enable = true;
  };

  home.packages = with pkgs; [
    cemu
  ];
}
