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
        steam-unwrapped = prev.steam-unwrapped.overrideAttrs (oldAttrs: {
          postInstall =
            builtins.replaceStrings [",steam,"]
            [",gamescope ${gsCfg.finalArgs} -- steam,"]
            oldAttrs.postInstall;
        });
      })
  ]
  ++ optionals enableGaming [
    inputs.umu-launcher.overlays.default
  ]
  ++ optionals (cfg.enable && cfg.manager == "wayland") [
    inputs.nixpkgs-wayland.overlay
  ]
