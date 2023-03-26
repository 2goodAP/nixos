{pkgs, ...}: {
  imports = [
    ./applications.nix
  ];

  config = {
    gtk = {
      enable = true;
      font = {
        package = pkgs.noto-nerd-font;
        name = "NotoSans Nerd Font";
        size = 11;
      };
      iconTheme = {
        package = pkgs.breeze-icons;
        name = "Breeze";
      };
      theme = {
        package = pkgs.libsForQt5.breeze-gtk;
        name = "Breeze";
      };
    };

    qt = {
      enable = true;
      style = {
        package = pkgs.libsForQt5.breeze-qt5;
        name = "Breeze";
      };
    };
  };
}
