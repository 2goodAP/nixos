{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./apps.nix
    ./display.nix
    ./overlays.nix
    ./theme.nix
    ./widgets.nix
  ];

  options.tgap.home.desktop.hyprland = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Whether or not to enable hyprland and related-packages.";
  };

  config = let
    cfg = config.tgap.home.desktop.hyprland;
    inherit (lib) getExe getExe' mkIf;
  in
    mkIf cfg.enable {
      wayland.windowManager.hyprland = {
        enable = true;

        package = inputs.hyprland.packages."${pkgs.system}".hyprland;
        plugins = [inputs.hy3.packages."${pkgs.system}".hy3];

        settings = {
          input = {
            kb_layout = "us,us,np";
            kb_variant = "altgr-intl,colemak_dh,";
            kb_options = "grp:alt_caps_toggle";
            follow_mouse = 2;
            float_switch_override_focus = 0;

            accel_profile = "adaptive";
            sensitivity = 0;
            scroll_method = "2fg";
            touchpad = {
              natural_scroll = true;
              middle_button_emulation = true;
              clickfinger_behavior = true;
              drag_lock = true;
            };
          };

          general = {
            resize_on_border = true;
          };

          gestures = {
            workspace_swipe = true;
          };

          device = {
            compx-fantech-heliosgo-pro-wireless-xd5 = {
              accel_profile = "flat";
            };
          };

          bind = [
            "SUPER, return, exec, ${getExe pkgs.kitty}"
            "SUPER SHIFT, q, killactive,"
            "SUPER SHIFT, e, exit,"
            "SUPER, space, togglefloating,"
            ''SUPER, r, exec, ${getExe' pkgs.rofi-wayland "rofi"} -show combi \
              -modes combi -combi-modes window,drun,run''
            "SUPER, p, pseudo," # dwindle
            "SUPER, m, togglesplit," # dwindle

            # Move focus with super + arrow keys
            "SUPER, h, movefocus, l"
            "SUPER, l, movefocus, r"
            "SUPER, k, movefocus, u"
            "SUPER, j, movefocus, d"

            # Switch workspaces with super + [0-9]
            "SUPER, 1, workspace, 1"
            "SUPER, 2, workspace, 2"
            "SUPER, 3, workspace, 3"
            "SUPER, 4, workspace, 4"
            "SUPER, 5, workspace, 5"
            "SUPER, 6, workspace, 6"
            "SUPER, 7, workspace, 7"
            "SUPER, 8, workspace, 8"
            "SUPER, 9, workspace, 9"
            "SUPER, 0, workspace, 10"

            # Move active window to a workspace with super + SHIFT + [0-9]
            "SUPER SHIFT, 1, movetoworkspace, 1"
            "SUPER SHIFT, 2, movetoworkspace, 2"
            "SUPER SHIFT, 3, movetoworkspace, 3"
            "SUPER SHIFT, 4, movetoworkspace, 4"
            "SUPER SHIFT, 5, movetoworkspace, 5"
            "SUPER SHIFT, 6, movetoworkspace, 6"
            "SUPER SHIFT, 7, movetoworkspace, 7"
            "SUPER SHIFT, 8, movetoworkspace, 8"
            "SUPER SHIFT, 9, movetoworkspace, 9"
            "SUPER SHIFT, 0, movetoworkspace, 10"

            # Scroll through existing workspaces with super + scroll
            "SUPER ALT, l, workspace, e+1"
            "SUPER ALT, h, workspace, e-1"
          ];

          # Move/resize windows with super + LMB/RMB and dragging
          bindm = [
            "SUPER, mouse:272, movewindow"
            "SUPER, mouse:273, resizewindow"
          ];
        };
      };
    };
}
