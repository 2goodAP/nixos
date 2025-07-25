{
  config,
  inputs,
  inputs',
  lib,
  ...
}: let
  cfg = config.tgap.system;
  enableGaming = cfg.desktop.enable && cfg.desktop.gaming.enable;
  inherit (lib) getExe optionalAttrs optionals;
in
  [
    inputs.ghostty.overlays.default
    inputs.neovim-nightly-overlay.overlays.default

    (final: prev:
      {
        wezterm = inputs'.wezterm.packages.default;

        iosevka-special =
          (prev.iosevka.override rec {
            set = "Special";

            privateBuildPlan = ''
              [buildPlans.Iosevka${set}]
              family = "Iosevka ${set}"
              spacing = "normal"
              serifs = "sans"
              noCvSs = true
              exportGlyphNames = true

              [buildPlans.Iosevka${set}.variants.design]
              three = "flat-top-serifless"
              four = "semi-open-non-crossing-serifless"
              five = "oblique-flat-serifless"
              seven = "curly-serifless"
              zero = "oval-tall-reverse-slashed"
              capital-a = "curly-serifless"
              capital-b = "more-asymmetric-interrupted-serifless"
              capital-d = "more-rounded-serifless"
              capital-g = "toothless-corner-serifless-hooked"
              capital-i = "short-serifed"
              capital-j = "descending-serifed-both-sides"
              capital-k = "curly-serifless"
              capital-p = "open-serifless"
              capital-q = "crossing-curly-tailed"
              capital-r = "curly-open-serifless"
              capital-u = "toothless-corner-serifless"
              capital-v = "curly-serifless"
              capital-x = "curly-serifless"
              capital-y = "curly-serifless"
              capital-z = "curly-serifless"
              a = "double-storey-toothless-corner"
              b = "toothless-corner-serifless"
              d = "toothless-corner-serifless"
              f = "extended"
              g = "single-storey-flat-hook-earless-corner"
              h = "tailed-serifless"
              i = "serifed-asymmetric"
              j = "diagonal-tailed-serifed"
              k = "curly-serifless"
              l = "serifed-semi-tailed"
              m = "earless-corner-double-arch-serifless"
              n = "earless-corner-straight-serifless"
              p = "earless-corner-serifless"
              q = "earless-corner-straight-serifless"
              r = "earless-corner-serifless"
              t = "diagonal-tailed"
              u = "toothless-corner-serifless"
              v = "curly-serifless"
              x = "semi-chancery-curly-serifless"
              y = "curly-serifless"
              z = "curly-serifless"
              capital-eszet = "flat-top-serifless"
              long-s = "flat-hook-tailed"
              eszet = "longs-s-lig-tailed-serifless"
              capital-delta = "curly"
              lower-eta = "motion-serifed"
              lower-theta = "oval"
              capital-lambda = "curly-serifless"
              lower-lambda = "curly-tailed-turn"
              lower-mu = "tailed-motion-serifed"
              partial-derivative = "closed-contour"
              cyrl-a = "double-storey-tailed"
              asterisk = "turn-hex-low"
              caret = "high"
              paren = "large-contour"
              brace = "curly-flat-boundary"
              ampersand = "upper-open"
              dollar = "slanted-interrupted"
              cent = "slanted-through"
              question = "corner-flat-hooked"
              pilcrow = "low"

              [buildPlans.Iosevka${set}.variants.italic]
              three = "flat-top-serifless"
              four = "semi-open-non-crossing-serifless"
              five = "oblique-flat-serifless"
              seven = "bend-serifless"
              zero = "oval-tall-reverse-slashed"
              capital-a = "curly-serifless"
              capital-b = "more-asymmetric-interrupted-serifless"
              capital-d = "more-rounded-serifless"
              capital-g = "toothless-corner-serifless-hooked"
              capital-i = "short-serifed"
              capital-j = "descending-serifed-both-sides"
              capital-k = "curly-serifless"
              capital-p = "open-serifless"
              capital-q = "open-swash"
              capital-r = "curly-open-serifless"
              capital-u = "toothless-corner-serifless"
              capital-v = "curly-serifless"
              capital-x = "curly-serifless"
              capital-y = "curly-serifless"
              capital-z = "cursive"
              a = "single-storey-earless-corner-tailed"
              b = "toothless-corner-serifless"
              d = "toothless-corner-serifless"
              e = "rounded"
              f = "tailed"
              g = "double-storey-open"
              h = "tailed-serifless"
              i = "flat-tailed"
              j = "serifless"
              k = "cursive-serifless"
              l = "tailed"
              m = "earless-rounded-double-arch-serifless"
              n = "earless-rounded-straight-serifless"
              p = "earless-corner-serifless"
              q = "earless-corner-straight-serifless"
              r = "earless-corner-serifless"
              t = "diagonal-tailed"
              u = "toothless-rounded-serifless"
              v = "cursive-serifless"
              w = "cursive-serifless"
              x = "cursive"
              y = "cursive-serifless"
              z = "cursive"
              capital-eszet = "flat-top-serifless"
              long-s = "flat-hook-tailed"
              eszet = "longs-s-lig-tailed-serifless"
              capital-delta = "curly"
              lower-eta = "motion-serifed"
              lower-theta = "oval"
              capital-lambda = "curly-serifless"
              lower-lambda = "curly-tailed-turn"
              lower-mu = "tailed-motion-serifed"
              partial-derivative = "closed-contour"
              cyrl-a = "double-storey-tailed"
              asterisk = "turn-hex-low"
              caret = "high"
              paren = "large-contour"
              brace = "curly-flat-boundary"
              ampersand = "upper-open"
              dollar = "slanted-interrupted"
              cent = "slanted-through"
              question = "corner"
              pilcrow = "low"

              [buildPlans.Iosevka${set}.ligations]
              inherits = "dlig"

              [buildPlans.Iosevka${set}.slopes.Upright]
              angle = 0
              shape = "upright"
              menu = "upright"
              css = "normal"

              [buildPlans.Iosevka${set}.slopes.Italic]
              angle = 9.4
              shape = "italic"
              menu = "italic"
              css = "italic"
            '';
          }).overrideAttrs (oldAttrs: {
            env.NIX_BUILD_CORES = "6";

            nativeBuildInputs =
              oldAttrs.nativeBuildInputs
              ++ (with final; [
                nerd-font-patcher
                ps
                ripgrep
              ]);

            postBuild = ''
              declare -i NCORES=${toString (
                if config.nix.settings.cores == 0
                then 8
                else config.nix.settings.cores
              )}
              declare -a pids
              distdir="dist/$pname"

              for font in "$distdir/TTF"/*.ttf; do
                until [ $(($(ps -e | rg 'nerd-font' | wc -l))) -lt $((NCORES)) ]; do
                  : # busy-wait
                done

                nerd-font-patcher "$font" --careful --makegroups 4 \
                  -out "$distdir/NerdFonts" --complete --no-progressbars &
                pids+=($!)
              done

              for pid in "''${pids[@]}"; do
                wait "$pid"
              done
            '';

            installPhase = ''
              runHook preInstall

              fontdir="$out/share/fonts/truetype"
              install -d "$fontdir/NerdFonts/$pname"
              install "dist/$pname/TTF"/*.ttf "$fontdir"
              install "dist/$pname/NerdFonts"/*.ttf "$fontdir/NerdFonts/$pname"

              runHook postInstall
            '';
          });

        soundfont-upright-kw = final.stdenv.mkDerivation {
          pname = "upright-kw";
          version = "unstable-2022-02-21";

          src = prev.fetchurl {
            url = "https://freepats.zenvoid.org/Piano/UprightPianoKW/UprightPianoKW-SF2-20220221.7z";
            sha256 = "sha256-F8CExuQgUjPcSbNOS8RKmy18eiwCsEcp7Np3B5sHyCY=";
          };

          unpackPhase = ''
            ${getExe final.p7zip} e $src
          '';

          installPhase = ''
            install -Dm644 UprightPianoKW-*.sf2 \
              $out/share/soundfonts/UprightPianoKW.sf2
          '';

          meta = with lib; {
            description = "Kawai upright piano soundfont";
            homepage = "https://freepats.zenvoid.org/Piano/acoustic-grand-piano.html";
            license = licenses.cc-by-30;
            platforms = platforms.all;
          };
        };

        soundfont-salamander-grand = final.stdenv.mkDerivation {
          pname = "salamander-grand";
          version = "3-unstable-2020-06-02";

          src = prev.fetchurl {
            url = "https://freepats.zenvoid.org/Piano/SalamanderGrandPiano/SalamanderGrandPiano-SF2-V3+20200602.tar.xz";
            sha256 = "sha256-Fe2wYde6YNWDMvctuo+M5AmIBIzHA/k15jIPN9ZQ4hM=";
          };

          installPhase = ''
            install -Dm644 SalamanderGrandPiano-*.sf2 \
              $out/share/soundfonts/SalamanderGrandPiano.sf2
          '';

          meta = with lib; {
            description = "Yamaha C5 grand piano soundfont";
            homepage = "https://freepats.zenvoid.org/Piano/acoustic-grand-piano.html";
            license = licenses.cc-by-30;
            platforms = platforms.all;
          };
        };

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

        vimPlugins = prev.vimPlugins.extend (_vfinal: _vprev: {
          haskell-tools-nvim = inputs'.haskell-tools-nvim.packages.default;
          lz-n = inputs'.lz-n.packages.default;
        });
      }
      // optionalAttrs (cfg.programs.defaultShell == "nushell") {
        nushellPlugins = prev.nushellPlugins.overrideScope (_nfinal: nprev: {
          skim = nprev.skim.overrideAttrs (oldAttrs: {
            postUnpack =
              (oldAttrs.postUnpack or "")
              + ''
                substituteInPlace ${oldAttrs.src.name}/src/main.rs \
                  --replace-fail \"sk\" \"sm\"
              '';
          });
        });
      }
      // optionalAttrs enableGaming {
        gamemode = prev.gamemode.overrideAttrs (oldAttrs: {
          postPatch =
            (oldAttrs.postPatch or "")
            + ''
              substituteInPlace data/gamemoderun \
                --replace-fail libgamemodeauto.so.0 \
                libgamemodeauto.so.0:libgamemode.so.0
            '';
        });
      })
  ]
  ++ optionals enableGaming [
    inputs.umu-launcher.overlays.default
  ]
  ++ optionals (cfg.desktop.enable && cfg.desktop.manager == "niri") [
    inputs.nixpkgs-wayland.overlay

    (final: prev: {
      flif = final.stdenv.mkDerivation (finalAttrs: {
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

      wuimg = final.stdenv.mkDerivation (finalAttrs: {
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
