{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  osCfg = osConfig.tgap.system.desktop;
  inherit (lib) getExe mkIf;

  fontSpec = "Jetbrains Mono Nerd Font:size=12:fontfeatures=calt,cv04,cv16,ss02,ss19";
  icon-theme = "Papirus";
in
  mkIf (osCfg.enable && osCfg.manager == "niri") {
    home.packages = with pkgs; [
      libnotify
      pavucontrol
      wallust
      wl-clipboard
      wuimg
      xwayland-satellite
    ];

    programs.fuzzel = {
      enable = true;
      settings.main = {
        font = fontSpec;
        use-bold = true;
        inherit icon-theme;
      };
    };

    services = {
      blueman-applet.enable = true;
      clipse.enable = true;
      hyprpaper.enable = true;
      network-manager-applet.enable = true;
      playerctld.enable = true;
      swayosd.enable = true;

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
      in {
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
          PartOf = [
            systemdTarget
            "tray.target"
          ];
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
      in {
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
          PartOf = [systemdTarget];
          After = [
            (builtins.replaceStrings
              [".target"] ["-pre.target"]
              systemdTarget)
          ];
        };
      };
    };
  }
