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

        bashdb = prev.stdenv.mkDerivation {
          inherit (prev.bashdb) pname meta;
          version = "${prev.bashdb.version}-unstable-2025-06-08";

          src = prev.fetchFromGitHub {
            owner = "Trepan-Debuggers";
            repo = "bashdb";
            rev = "7d0f9751e04fa54f48f0ab4be32ecb8030a4315d";
            sha256 = "sha256-fwxmlFC66Lv+zD632s9a44I9IEQ/82caKnQ44pdVes4=";
          };

          env.NOCONFIGURE = 1;

          nativeBuildInputs = with final; [
            autoconf
            automake
            bashInteractive
            fd
            perl
            texi2html
            texinfo
          ];

          buildInputs = [
            (final.python3.withPackages (ps: [ps.pygments]))
          ];

          patches = [./patches/bashdb_fix_nixos_builds_for_bash_5.3.patch];

          preConfigure = "patchShebangs .";
          configurePhase = ''
            runHook preConfigure

            ./autogen.sh
            ./configure --prefix=$out

            runHook postConfigure
          '';
        };

        ariang-allinone = let
          ariang-aio = prev.ariang.overrideAttrs {
            pname = "ariang-aio";

            buildPhase = ''
              runHook preBuild

              ./node_modules/gulp/bin/gulp.js clean build-bundle

              runHook postBuild
            '';
          };
        in
          prev.symlinkJoin {
            name = "AriaNg-AllInOne";
            paths = [
              ariang-aio

              (prev.writeShellApplication {
                name = "ariang";
                runtimeInputs = with final; [
                  aria2
                  xdg-utils
                ];
                text = ''
                  function show_help() {
                  cat <<EOF
                  Usage:
                    ''${0##*/} [-h|--help] <secret-token>
                  EOF
                  }

                  if [ -z "''${1:+x}" ]; then
                    printf "%s\n" "''${0##*/}: missing secret token" >&2
                    show_help >&2
                    exit 1
                  elif  [[ "$1" = "-h" || "$1" == "--help" ]]; then
                    show_help
                    exit 0
                  fi

                  # Start aria2 RPC server in the background
                  aria2c --enable-rpc=true --rpc-allow-origin-all=true --rpc-secret="$1" &

                  aria_pid=$!
                  base64_secret="$(base64 <(printf "%s" "$1"))"
                  unset "$1"

                  # Wait for the server to start
                  sleep 2

                  # Open the ariang WebUI
                  xdg-open "file://${ariang-aio}/share/ariang/index.html#!/settings/rpc/set?protocol=http&host=localhost&port=6800&interface=jsonrpc&secret=''${base64_secret%%=*}"

                  # Wait for the aria2 RPC server to stop
                  wait "$aria_pid"
                '';
              })
            ];
          };

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

        typescript-styled-plugin = prev.buildNpmPackage (finalAttrs: {
          pname = "typescript-styled-plugin";
          version = "1.0.1";

          src = prev.fetchFromGitHub {
            owner = "styled-components";
            repo = "typescript-styled-plugin";
            rev = "v${finalAttrs.version}";
            hash = "sha256-lTacDVY/E14EaTCmpk99wwjoWdTZh6A1goAnw3TEY/k=";
          };

          npmDepsHash = "sha256-WhPxYS9lgycWSqdiVEdHv7oVSwCF+G65LMUibXIkJII=";
          dontNpmBuild = true;
          passthru.updateScript = prev.nix-update-script {};

          meta = {
            description =
              "TypeScript server plugin that adds "
              + "intellisense to styled component css strings";
            homepage = "https://github.com/styled-components/typescript-styled-plugin";
            license = lib.licenses.mit;
          };
        });

        vimPlugins = prev.vimPlugins.extend (_vfinal: _vprev: {
          haskell-tools-nvim = inputs'.haskell-tools-nvim.packages.default;
          lz-n = inputs'.lz-n.packages.default;
        });

        vscode-bash-debug = prev.vscode-utils.buildVscodeExtension (finalAttrs: {
          pname = "vscode-bash-debug";
          version = "0.3.9-unstable-2021-02-15";
          vscodeExtPublisher = "rogalmic";
          vscodeExtName = "vscode-bash-debug";
          vscodeExtUniqueId =
            "${finalAttrs.vscodeExtPublisher}"
            + ".${finalAttrs.vscodeExtName}";

          src = prev.fetchzip {
            url = "https://github.com/rogalmic/vscode-bash-debug/releases/download/untagged-438733f35feb8659d939/bash-debug-0.3.9.vsix";
            stripRoot = false;
            extension = "zip";
            sha256 = "sha256-CNwhxbnGm5H0Swkurw9LXW21dHR6OA3uw1GtmlMaLk0=";
          };

          sourceRoot = "${finalAttrs.src.name}/extension";
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
