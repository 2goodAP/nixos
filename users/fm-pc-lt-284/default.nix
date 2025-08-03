{
  imports = [
    ../common
    ./programs.nix
  ];

  fonts.fontconfig.enable = true;

  tgap.home = {
    desktop.applications.extras.enable = true;

    programs = {
      neovim.enable = true;

      applications = {
        extras.enable = true;
        jupyter.enable = true;
      };
    };
  };

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

    localsendGL = {
      categories = ["Network"];
      comment = "Localsend over nixGL";
      exec = "nixGLIntel localsend_app";
      genericName = "An open source cross-platform alternative to AirDrop";
      icon = "localsend";
      name = "LocalSend GL";
      settings.StartupWMClass = "localsend_app";
    };

    sioyekGL = {
      categories = ["Development" "Viewer"];
      comment = "Sioyek over nixGL";
      exec = "nixGLIntel sioyek %f";
      genericName = "PDF viewer for reading research papers and technical books";
      icon = "sioyek-icon-linux";
      mimeType = ["application/pdf"];
      name = "Sioyek GL";
      settings = {
        Keywords = "pdf;viewer;reader;research";
        StartupNotify = "true";
      };
    };

    weztermGL = {
      categories = ["System" "TerminalEmulator" "Utility"];
      comment = "Wez's Terminal Emulator over nixGL";
      exec = "nixGLIntel wezterm start --cwd .";
      genericName = "Terminal Emulator";
      icon = "org.wezfurlong.wezterm";
      name = "WezTerm GL";
      settings = {
        Keywords = "shell;prompt;command;commandline;cmd";
        StartupWMClass = "org.wezfurlong.wezterm";
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
