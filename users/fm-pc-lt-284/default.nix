{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common
    ./programs
  ];

  tgap.home.desktop.nixosApplications.enable = false;

  home.packages = with pkgs; [
    aws-workspaces
    insomnia
    (nerdfonts.override {fonts = ["CascadiaCode" "FiraCode"];})
    openvpn
    slack
  ];
}
