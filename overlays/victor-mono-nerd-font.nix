# An overlay for the latest version of Victor Mono Nerd Font.

self: super: {
  victor-mono-nerd-font = let
    version = "2.2.2";
  in super.fetchzip rec {
    name = "victor-mono-nerd-font-${version}";
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/VictorMono.zip";
    
    stripRoot = false;

    postFetch = ''
      mkdir -p $out/share/{fonts/truetype,doc/${name}}
      mv $out/*.ttf $out/share/fonts/truetype
      mv $out/*.md $out/share/doc/${name}
      mv $out/LICENSE* $out/share/doc/${name}
    '';

    sha256 = "sha256-5bl22eFv6TnnB9lgFNvlxbxsP86PIvjV5fMi9JqJTJw=";
  };
}
