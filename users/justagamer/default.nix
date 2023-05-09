{pkgs, ...}: {
  imports = [../common];

  tgap.user.desktop = {
    nixosApplications.enable = true;
    gaming.enable = true;
  };
}
