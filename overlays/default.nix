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
        gamescope = prev.gamescope.overrideAttrs {
          version = "3.14.29-rev94271f3";
          src = prev.fetchFromGitHub {
            owner = "ValveSoftware";
            repo = "gamescope";
            rev = "94271f317e438b82e99e2a2949f3f9dff27f62e4";
            fetchSubmodules = true;
            hash = "sha256-pVOSnPWXD5QFTk3vNsngLlevkzMlbO5UwGeY0URIt34=";
          };
        };

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
