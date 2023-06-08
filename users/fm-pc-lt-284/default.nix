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

  tgap.user.desktop.nixosApplications.enable = false;

  home.packages = with pkgs; [
    insomnia
    (nerdfonts.override {fonts = ["CascadiaCode" "FiraCode"];})
    openvpn
  ];
}
