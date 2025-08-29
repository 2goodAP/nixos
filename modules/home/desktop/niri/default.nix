{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ./applications.nix
    ./display.nix
  ];

  config = let
    cfg = config.tgap.home.desktop;
    osCfg = osConfig.tgap.system.desktop;
    inherit (lib) getExe mapAttrsToList mkIf optionalAttrs;

    templates =
      {
        "%XKB_LAYOUT%" = osConfig.services.xserver.xkb.layout;
        "%XKB_VARIANT%" = osConfig.services.xserver.xkb.variant;
        "%XKB_OPTIONS%" =
          builtins.replaceStrings
          ["grp:menu_toggle"] ["grp:ctrls_toggle"]
          osConfig.services.xserver.xkb.options;

        "%NIRI_TMP%" = "$XDG_RUNTIME_DIR/niri";
        "%SNKVOLPIPE%" = "${templates."%NIRI_TMP%"}/snkvolpipe";
        "%SRCVOLPIPE%" = "${templates."%NIRI_TMP%"}/srcvolpipe";
        "%SCRSHTPNG%" = "${config.xdg.cacheHome}/niri/screenshot.png";

        "%SNK_VOL%" = "wpctl get-volume @DEFAULT_SINK@ 2> /dev/null | cut -d ' ' -f 2";
        "%SRC_VOL%" = "wpctl get-volume @DEFAULT_SOURCE@ 2> /dev/null | cut -d ' ' -f 2";
      }
      // optionalAttrs (cfg.terminal.name == "foot") {
        "%TERMINAL%" = ''"foot"'';
        "%CLIPSE%" = ''"foot" "--app-id=clipse" "--" "clipse"'';
      }
      // optionalAttrs (cfg.terminal.name == "ghostty") {
        "%TERMINAL%" = ''"ghostty"'';
        "%CLIPSE%" = ''"ghostty" "--class=org.clipse" "-e" "clipse"'';
      }
      // optionalAttrs (cfg.terminal.name == "wezterm") {
        "%TERMINAL%" = ''"wezterm" "start" "--cwd" "."'';
        "%CLIPSE%" = ''"wezterm" "start" "--class" "clipse" "--" "clipse"'';
      };
  in
    mkIf (osCfg.enable && osCfg.manager == "niri" && cfg.enable) {
      home.activation.activateQtctConfig = let
        qt5ctConf = builtins.readFile ./qtct/qt5ct.conf;
        qt6ctConf = builtins.readFile ./qtct/qt6ct.conf;
        qt5ctConfFile = "${config.xdg.configHome}/qt5ct/qt5ct.conf";
        qt6ctConfFile = "${config.xdg.configHome}/qt6ct/qt6ct.conf";
      in
        lib.hm.dag.entryAfter ["linkGeneration"] ''
          # Ensure that qt5ct.conf and qt6ct.conf exist
          mkdir -p ${dirOf qt5ctConfFile}
          mkdir -p ${dirOf qt6ctConfFile}
          touch ${qt5ctConfFile}
          touch ${qt6ctConfFile}

          # Replace relevant parts of the configs
          # qt5ct
          ${getExe pkgs.gawk} -Oi inplace -v INPLACE_SUFFIX=.hm.bak \
            '/^\s*\[/ {found = 0} $0 ~ "${
            lib.concatStringsSep "|" (lib.flatten
              (lib.partition (e: lib.isList e)
                (builtins.split "[[]([[:alpha:]]+)[]]" qt5ctConf))
              .right)
          }" {found = 1; next} !found' ${qt5ctConfFile}
          cat >> ${qt5ctConfFile} << EOF
          ${builtins.replaceStrings ["@configDir@"]
            [(dirOf qt5ctConfFile)]
            qt5ctConf}
          EOF

          # qt6ct
          ${getExe pkgs.gawk} -Oi inplace -v INPLACE_SUFFIX=.hm.bak \
            '/^\s*\[/ {found = 0} $0 ~ "${
            lib.concatStringsSep "|" (lib.flatten
              (lib.partition (e: lib.isList e)
                (builtins.split "[[]([[:alpha:]]+)[]]" qt6ctConf))
              .right)
          }" {found = 1; next} !found' ${qt6ctConfFile}
          cat >> ${qt6ctConfFile} << EOF
          ${builtins.replaceStrings ["@configDir@"]
            [(dirOf qt6ctConfFile)]
            qt6ctConf}
          EOF
        '';

      gtk = {
        enable = true;
        gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

        font = {
          name = "Noto Sans";
          package = pkgs.noto-fonts;
          size = 10;
        };

        iconTheme = {
          name = "Papirus";
          package = pkgs.papirus-icon-theme;
        };

        theme = {
          name = "Adwaita";
          package = pkgs.gnome-themes-extra;
        };
      };

      home = {
        sessionVariables.QT_QUICK_CONTROLS_STYLE = "org.kde.breeze";

        packages =
          [pkgs.bibata-cursors]
          ++ (with pkgs.kdePackages; [
            breeze
            breeze.qt5
            qqc2-breeze-style
          ]);

        pointerCursor = {
          gtk.enable = true;
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
          size = 24;
        };
      };

      qt = {
        enable = true;
        platformTheme.name = "qtct";
      };

      xdg.configFile = {
        "eww/eww.scss".source = ./eww/eww.scss;
        "qt5ct/style-colors.conf".source = ./qtct/qt5-style-colors.conf;
        "qt6ct/style-colors.conf".source = ./qtct/qt6-style-colors.conf;

        "eww/eww.yuck".text =
          builtins.replaceStrings
          (mapAttrsToList (name: _: name) templates)
          (mapAttrsToList (_: value: value) templates)
          (builtins.readFile ./eww/eww.yuck);

        "niri/config.kdl".text =
          builtins.replaceStrings
          (mapAttrsToList (name: _: name) templates)
          (mapAttrsToList (_: value: value) templates)
          (builtins.readFile ./niri-config.kdl);
      };
    };
}
