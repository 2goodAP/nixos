# An overlay for the latest version of Rototo Mono Nerd Font.

self: super: {
  noto-nerd-font = let
    version = "2.2.2";
  in
    super.fetchzip rec {
      name = "noto-nerd-font-${version}";
      url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/Noto.zip";

      stripRoot = false;

      postFetch = ''
        mkdir -p $out/share/{fonts/truetype,doc/${name}}
        mv $out/*.ttf $out/share/fonts/truetype
        mv $out/*.md $out/share/doc/${name}
        mv $out/LICENSE* $out/share/doc/${name}
      '';

      sha256 = "sha256-qoXLq9LLoQ4Nw0R/hiGK6nPSpx2n2Agxxf4nyXESf3M=";
    };
}
