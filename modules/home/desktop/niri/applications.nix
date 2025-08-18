{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop;
  osCfg = osConfig.tgap.system.desktop;
  inherit (lib) getExe mkIf;

  fontSpec = "Jetbrains Mono Nerd Font:size=12:fontfeatures=calt,cv04,cv16,ss02,ss19";
  icon-theme = "Papirus";
in
  mkIf (osCfg.enable && osCfg.manager == "niri" && cfg.enable) {
    home.packages = with pkgs; [
      glib
      inotify-tools
      libnotify
      pavucontrol
      swappy
      wallust
      wl-clipboard
      wuimg
      xwayland-satellite
    ];

    programs = {
      eww.enable = true;

      fuzzel = {
        enable = true;
        settings.main = {
          font = fontSpec;
          use-bold = true;
          inherit icon-theme;
        };
      };

      niriswitcher = {
        enable = true;
        settings = {
          current_output_only = true;
          appearance.system_theme = "auto";
        };
      };
    };

    services = {
      blueman-applet.enable = true;
      hyprpaper.enable = true;
      network-manager-applet.enable = true;
      playerctld.enable = true;
      swayosd.enable = true;

      clipse = {
        enable = true;
        systemdTarget = config.wayland.systemd.target;
        imageDisplay.type =
          if (builtins.elem cfg.terminal.name ["ghostty" "wezterm"])
          then "kitty"
          else "sixel";

        theme = {
          useCustomTheme = true;
          TitleFore = "#575279";
          TitleBack = "#f2e9e1";
          TitleInfo = "#56949f";
          NormalTitle = "#575279";
          NormalDesc = "#9893a5";
          SelectedTitle = "#d7827e";
          DimmedTitle = "#cecacd";
          DimmedDesc = "#cecacd";
          SelectedDesc = "#ea9d34";
          StatusMsg = "#56949f";
          PinIndicatorColor = "#286983";
          SelectedBorder = "#286983";
          SelectedDescBorder = "#286983";
          FilteredMatch = "#907aa9";
          FilterPrompt = "#b4637a";
          FilterInfo = "#907aa9";
          FilterText = "#575279";
          FilterCursor = "#907aa9";
          HelpKey = "#797593";
          HelpDesc = "#9893a5";
          PageActiveDot = "#286983";
          PageInactiveDot = "#9893a5";
          DividerDot = "#286983";
          PreviewedText = "#575279";
          PreviewBorder = "#286983";
        };
      };

      fnott = {
        enable = true;
        settings = {
          main = {
            default-timeout = 30;
            border-radius = 10;
            body-font = fontSpec;
            summary-font = fontSpec;
            title-font = fontSpec + ":weight=bold";
            inherit icon-theme;
          };
        };
      };

      udiskie = {
        enable = true;
        settings = {
          icon_names.media = ["media-optical"];
          program_options.udisks_version = 2;
        };
      };
    };

    systemd.user.services = let
      systemdTarget = config.wayland.systemd.target;
    in {
      eww = let
        eww = config.programs.eww.package;
      in rec {
        Install.WantedBy = [
          systemdTarget
          "tray.target"
        ];

        Service = {
          ExecReload = "${getExe eww} reload";
          ExecStart = "${getExe eww} daemon";
          ExecStop = "${getExe eww} kill";
          RemainAfterExit = "true";
          Restart = "on-failure";
          Type = "oneshot";
        };

        Unit = {
          Description =
            "Eww is a widget system made in Rust,"
            + " which lets you create your own widgets.";
          Documentation = "https://elkowar.github.io/eww";
          After = [systemdTarget];
          PartOf = Install.WantedBy;
        };
      };

      plasma-polkit-agent = let
        polkit-kde-agent-1 = pkgs.kdePackages.polkit-kde-agent-1.override (old: {
          mkKdeDerivation = args:
            old.mkKdeDerivation (args
              // {
                extraPropagatedBuildInputs = with pkgs.kdePackages; [
                  kirigami
                  qqc2-breeze-style
                ];
              });
        });
      in rec {
        Install.WantedBy = [systemdTarget];

        Service = {
          ExecStart = "${polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
          BusName = "org.kde.polkit-kde-authentication-agent-1";
          Slice = "background.slice";
          TimeoutStopSec = "5sec";
          Restart = "on-failure";
        };

        Unit = {
          Description = "KDE PolicyKit Authentication Agent";
          PartOf = Install.WantedBy;
          After = Install.WantedBy;
        };
      };
    };

    xdg.configFile."swappy/config".text = ''
      [Default]
      save_dir=$HOME/Pictures/Screenshots
      save_filename_format=Screenshot-%Y%m%d-%H%M%S.png
    '';
  }
