{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common
    ./programs
  ];

  tgap.home = {
    desktop.nixosApplications.enable = false;
    programs = {
      enable = true;
      jupyter.enable = true;
    };
  };

  home.packages = with pkgs; [
    aws-workspaces
    insomnia
    (nerdfonts.override {fonts = ["CascadiaCode" "FiraCode"];})
    openvpn
    slack
  ];

  xdg.desktopEntries = {
    firefoxGL = {
      categories = ["Network" "WebBrowser"];
      comment = "Mozilla Firefox over nixGL";
      exec = "nixGLIntel firefox --name firefox %U";
      genericName = "Web Browser";
      icon = "firefox";
      name = "Firefox GL";
      actions = {
        new-private-window = {
          exec = "nixGLIntel firefox --private-window %U";
          name = "New Private Window";
        };
        new-window = {
          exec = "nixGLIntel firefox --new-window %U";
          name = "New Window";
        };
        profile-manager = {
          exec = "nixGLIntel firefox --ProfileManager %U";
          name = "Profile Manager";
        };
      };
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/vnd.mozilla.xul+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      settings = {
        StartupNotify = "true";
        StartupWMClass = "firefox";
      };
    };

    workspacesGL = {
      categories = ["Development"];
      comment = "Amazon Workspaces Client over nixGL";
      exec = "nixGLIntel workspacesclient";
      genericName = "Remote Desktop Portal";
      icon = "com.amazon.workspaces";
      name = "WorkspacesClient GL";
      settings = {
        StartupNotify = "true";
        StartupWMClass = "workspacesclient";
      };
    };
  };
}
