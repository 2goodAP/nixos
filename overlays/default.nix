{
  config,
  inputs,
  lib,
  system,
  ...
}: let
  cfg = config.tgap.system;
  gsCfg = config.tgap.system.desktop.gaming.gamescope;
  inherit (lib) optionals;
in {
  overlays =
    [
      (final: prev: {
        wezterm = inputs.wezterm.packages.${system}.default;
      })
    ]
    ++ optionals cfg.laptop.enable [
      (final: prev: {
        nbfc-linux = inputs.nbfc-linux.defaultPackage.${system};
      })
    ]
    ++ optionals (cfg.desktop.enable && cfg.desktop.gaming.enable) [
      (final: prev: {
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
    ++ optionals (cfg.desktop.enable && cfg.desktop.manager == "wayland") [
      inputs.nixpkgs-wayland.overlay
    ];
}
