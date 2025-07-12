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
    ./widgets.nix
  ];

  config = let
    cfg = config.tgap.home.desktop;
    osCfg = osConfig.tgap.system;
    inherit (lib) getExe mapAttrsToList mkIf optionalAttrs;

    configTemplates =
      {
        "%XKB_LAYOUT%" = osConfig.services.xserver.xkb.layout;
        "%XKB_VARIANT%" = osConfig.services.xserver.xkb.variant;
        "%XKB_OPTIONS%" =
          builtins.replaceStrings
          ["grp:menu_toggle"] ["grp:ctrls_toggle"]
          osConfig.services.xserver.xkb.options;

        "%NIRI_TMP%" = "$XDG_RUNTIME_DIR/niri";
        "%SNKVOLPIPE%" = "snkvolpipe";
        "%SRCVOLPIPE%" = "srcvolpipe";
      }
      // optionalAttrs (cfg.terminal.name == "foot") {
        "%LAUNCH_TERMINAL%" = ''Mod+Return { spawn "foot"; }'';
        "%LAUNCH_CLIPSE%" = ''
          Mod+C { spawn "foot" "--app-id=clipse" "--" "clipse"; }
        '';
      }
      // optionalAttrs (cfg.terminal.name == "ghostty") {
        "%LAUNCH_TERMINAL%" = ''Mod+Return { spawn "ghostty"; }'';
        "%LAUNCH_CLIPSE%" = ''
          Mod+C { spawn "ghostty" "--class=org.clipse" "-e" "clipse"; }
        '';
      }
      // optionalAttrs (cfg.terminal.name == "wezterm") {
        "%LAUNCH_TERMINAL%" = ''Mod+Return { spawn "wezterm" "start" "--cwd" "."; }'';
        "%LAUNCH_CLIPSE%" = ''
          Mod+C { spawn "wezterm" "start" "--class" "clipse" "--" "clipse"; }
        '';
      };
  in
    mkIf (osCfg.desktop.enable && osCfg.desktop.manager == "niri") {
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

        iconTheme = {
          name = "Papirus";
          package = pkgs.papirus-icon-theme;
        };

        theme = {
          name = "Breeze";
          package = pkgs.kdePackages.breeze-gtk;
        };
      };

      home = {
        sessionVariables.QT_QUICK_CONTROLS_STYLE = "org.kde.breeze";

        packages = with pkgs; [
          bibata-cursors
          kdePackages.breeze
          kdePackages.breeze.qt5
          kdePackages.qqc2-breeze-style
          libsForQt5.qqc2-breeze-style
        ];

        pointerCursor = {
          gtk.enable = true;
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
          size = 24;
        };
      };

      programs.eww = let
        configDir = pkgs.runCommand "eww-config-dir" {} ''
          mkdir $out

          # eww.scss
          echo '${builtins.replaceStrings ["'"] ["'\"'\"'"]
            (builtins.readFile ./eww/eww.scss)}' > $out/eww.scss

          # eww.yuck
          echo '${builtins.replaceStrings
            (["'"] ++ (mapAttrsToList (name: _: name) configTemplates))
            (["'\"'\"'"] ++ (mapAttrsToList (_: value: value) configTemplates))
            (builtins.readFile ./eww/eww.yuck)}' > $out/eww.yuck
        '';
      in {
        enable = true;
        inherit configDir;
      };

      qt = {
        enable = true;
        platformTheme.name = "qtct";
      };

      xdg.configFile = {
        "qt5ct/style-colors.conf".source = ./qtct/qt5-style-colors.conf;
        "qt6ct/style-colors.conf".source = ./qtct/qt6-style-colors.conf;

        "niri/config.kdl".text =
          builtins.replaceStrings
          (mapAttrsToList (name: _: name) configTemplates)
          (mapAttrsToList (_: value: value) configTemplates)
          (builtins.readFile ./niri-config.kdl);
      };
    };
}
