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

  fonts.fontconfig.enable = true;
  tgap.user.programs.jupyter.enable = true;

  home.packages = with pkgs; [
    insomnia
    (nerdfonts.override {fonts = ["CascadiaCode" "FiraCode"];})
    openvpn
  ];
}
