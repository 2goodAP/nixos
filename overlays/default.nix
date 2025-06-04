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
      {
        wezterm = inputs.wezterm.packages.${system}.default;

        soundfont-generaluser = prev.soundfont-generaluser.overrideAttrs (oldAttrs: {
          version = "2.0.2";

          src = prev.fetchzip {
            url = "https://drive.usercontent.google.com/download?id=1UJ1mrY2l_C_YbKeyywNUymBz7OTVzQLU&export=download&confirm=t&uuid=1f4f2f5d-584d-4a1f-b123-7567cca1bdcf";
            extension = "zip";
            stripRoot = true;
            sha256 = "sha256-Jp1VMym8rItw7ELlpCGGvuc0zn1fBYzpYP5GhdcrXuA=";
          };

          installPhase =
            oldAttrs.installPhase
            + ''
              mkdir -p $out/share/doc/soundfont-generaluser
              install -Dm644 documentation/* $out/share/doc/soundfont-generaluser
            '';
        });

        qmk = prev.qmk.overrideAttrs (oldAttrs: {
          propagatedBuildInputs =
            oldAttrs.propagatedBuildInputs
            ++ [final.python3.pkgs.appdirs];
        });

        rename = prev.rename.override (old: {
          perlPackages =
            old.perlPackages
            // {
              buildPerlPackage = args:
                old.perlPackages.buildPerlPackage (args
                  // rec {
                    version = "1.16.3";

                    src = prev.fetchFromGitHub {
                      owner = "pstray";
                      repo = "rename";
                      rev = "v${version}";
                      sha256 = "sha256-KQsBO94fsa4CbTHNyJxOD96AwUfKNLa9p44odlNgQao=";
                    };
                  });
            };
        });
      }
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
  ++ optionals (cfg.enable && cfg.manager == "niri") [
    inputs.nixpkgs-wayland.overlay

    (final: prev: {
      flif = prev.stdenv.mkDerivation (finalAttrs: {
        pname = "flif";
        version = "0.4";

        src = prev.fetchFromGitHub {
          owner = "FLIF-hub";
          repo = "FLIF";
          tag = "v${finalAttrs.version}";
          hash = "sha256-S2RYno5u50jCgu412yMeXxUoyQzeaCqr8U13XC43y8o=";
        };

        postUnpack = ''
          sourceRoot=''${sourceRoot}/src
          echo Source root reset to ''${sourceRoot}
        '';

        nativeBuildInputs = [final.pkg-config];
        buildInputs = [final.libpng];

        installPhase = ''
          runHook preInstall

          make install PREFIX=$out
          make install-dev PREFIX=$out

          runHook postInstall
        '';

        outputs = [
          "out"
          "dev"
          "man"
        ];

        meta = with lib; {
          description = "Free Lossless Image Format";
          homepage = "https://flif.info";
          license = licenses.lgpl3Plus;
          mainProgram = "flif";
          platforms = platforms.unix;
          longDescription = ''
            A novel lossless image format which outperforms PNG,
            lossless WebP, lossless BPG, lossless JPEG2000,
            and lossless JPEG XR in terms of compression ratio.
          '';
        };
      });

      swappy = prev.swappy.overrideAttrs (oldAttrs: {
        version = "1.5.1-unstable-2024-11-17";

        src = prev.fetchFromGitHub {
          owner = "jtheoof";
          repo = oldAttrs.pname;
          rev = "2aa3ae2433ee671ddc73e36ece8598e68f7f3632";
          hash = "sha256-9fpGmGgHEYSZCXS7mkojnaQhD+OJMxocaz+dXShvF68=";
        };
      });

      wuimg = prev.stdenv.mkDerivation (finalAttrs: {
        pname = "wuimg";
        version = "1.0";

        src = prev.fetchFromGitea {
          domain = "codeberg.org";
          owner = "kaleido";
          repo = "wuimg";
          tag = "v${finalAttrs.version}";
          hash = "sha256-dPcfgp1RZ6TlyaO+qjcFM7fZlX1bUJcYhb2Nn05tASQ=";
        };

        mesonFlags = ["-Dwindow_glfw=disabled"];

        strictDeps = true;

        nativeBuildInputs = with final; [
          meson
          ninja
          pkg-config
          python3
          wayland-scanner
        ];

        buildInputs = with final; [
          # Minimum
          libarchive
          libepoxy
          exiv2
          icu
          lcms
          libuchardet

          # Wayland
          wayland
          libGL
          libxkbcommon
          wayland-protocols

          # DRM/KMS
          libdrm
          libgbm

          # Image decoding
          zlib
          libavif
          flif
          giflib
          libheif
          jbigkit
          jbig2dec
          libjpeg
          openjpeg
          charls
          libjxl
          lerc
          libpng
          libraw
          librsvg
          libtiff
          libwebp
        ];

        buildPhase = ''
          runHook preBuild

          meson compile
          meson compile wuconv

          runHook postBuild
        '';

        postInstall = ''
          install -Dm755 src/wuconv $out/bin
        '';

        meta = with lib; {
          description = "Minimalistic but not barebones image viewer";
          homepage = "https://codeberg.org/kaleido/wuimg";
          license = licenses.bsd0;
          platforms = platforms.linux;
          mainProgram = "wu";
          longDescription = ''
            wu is a minimalistic but not barebones image viewer. It aims for comfort,
            speed, accurate color rendering, and format documentation/preservation.
            wu is meant as a terminal companion, so launching from one is recommended.
          '';
        };
      });
    })
  ]
