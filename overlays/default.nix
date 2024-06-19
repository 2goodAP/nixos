{
  config,
  inputs,
  lib,
  system,
  ...
}: let
  cfg = config.tgap.system;
  inherit (lib) optionals;
in {
  overlays =
    [
      (final: prev: {
        noto-fonts = prev.noto-fonts.overrideAttrs (olds: {
          installPhase =
            builtins.replaceStrings ["unhinted"] ["hinted"] olds.installPhase;
        });
      })
    ]
    ++ (optionals cfg.laptop.enable [
      (final: prev: {
        nbfc-linux = inputs.nbfc-linux.defaultPackage.${system};
      })
    ])
    ++ (optionals (cfg.desktop.enable && cfg.desktop.manager == "wayland") [
      inputs.nixpkgs-wayland.overlay
    ]);
}
