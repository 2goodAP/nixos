{pkgs, ...}: {
  imports = [
    ./applications.nix
    ./sway.nix
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
        package = pkgs.papirus-icon-theme;
        name = "Papirus";
      };
      theme = {
        package = pkgs.gnome.gnome-themes-extra;
        name = "Adwaita";
      };
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
      style = {
        package = pkgs.adwaita-qt;
        name = "Adwaita";
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors-white";
      size = 36;
    };
  };
}
