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
            ''
              local out_font=$out/share/fonts/noto
            ''
            + (
              if olds._variants == []
              then ''
                for folder in $(ls -d fonts/*/); do
                  install -m444 -Dt $out_font "$folder"hinted/ttf/*.ttf
                done
              ''
              else ''
                for variant in $_variants; do
                  install -m444 -Dt $out_font fonts/"$variant"/hinted/ttf/*.ttf
                done
              ''
            );
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
