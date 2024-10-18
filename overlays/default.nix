{
  config,
  inputs,
  lib,
  system,
  ...
}: let
  cfg = config.tgap.system.desktop;
  gsCfg = cfg.gaming.gamescope;
  enableGaming = cfg.enable && cfg.gaming.enable;
  inherit (lib) optionalAttrs optionals;
in
  [
    (final: prev:
      {wezterm = inputs.wezterm.packages.${system}.default;}
      // optionalAttrs enableGaming {
        umu-launcher = inputs.umu-launcher.packages.${system}.umu;

        gamemode = prev.gamemode.overrideAttrs (oldAttrs: {
          postPatch =
            oldAttrs.postPatch
            + ''
              substituteInPlace data/gamemoderun \
                --replace-fail libgamemodeauto.so.0 \
                libgamemodeauto.so.0:libgamemode.so.0
            '';
        });
      }
      // optionalAttrs (enableGaming && cfg.gaming.steam.enable) {
        steamPackages = prev.steamPackages.overrideScope (sf: sp: {
          steam = sp.steam.overrideAttrs (oldAttrs: {
            postInstall =
              builtins.replaceStrings [",steam,"]
              [",gamescope ${gsCfg.finalArgs} -- steam,"]
              oldAttrs.postInstall;
          });
        });
      })
  ]
  ++ optionals (cfg.enable && cfg.manager == "wayland") [
    inputs.nixpkgs-wayland.overlay
  ]
