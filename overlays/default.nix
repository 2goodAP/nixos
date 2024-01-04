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
    (optionals cfg.laptop.enable [
      (final: prev: {
        nbfc-linux = inputs.nbfc-linux.defaultPackage.${system};
      })
    ])
    ++ (optionals (cfg.desktop.enable && cfg.desktop.manager == "wayland") [
      inputs.nixpkgs-wayland.overlay
    ])
    ++ (optionals (cfg.desktop.enable && cfg.desktop.gaming.enable) [
      (final: prev: {
        ryujinx = prev.ryujinx.overrideAttrs (oldAttrs: {
          preFixup = ''
            mkdir -p $out/share/{applications,icons/hicolor/scalable/apps,mime/packages}
            pushd $src/distribution/linux

            install -D ./Ryujinx.desktop $out/share/applications/Ryujinx.desktop
            install -D ./mime/Ryujinx.xml $out/share/mime/packages/Ryujinx.xml
            install -D ../misc/Logo.svg $out/share/icons/hicolor/scalable/apps/Ryujinx.svg

            substituteInPlace $out/share/applications/Ryujinx.desktop \
              --replace "Ryujinx.sh %f" \
              "env DOTNET_EnableAlternateStackCheck=1 ${prev.lib.getExe' final.gamemode "gamemoderun"} $out/bin/Ryujinx %f"

            ln -s $out/bin/Ryujinx $out/bin/ryujinx

            popd
          '';
        });
      })
    ]);
}
