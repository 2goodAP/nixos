# An overlay for the latest version of Fantasque Sans Nerd Font.
self: super: {
  fantasque-sans-mono = let
    version = "2.2.1";
  in
    super.fetchzip rec {
      name = "fantasque-sans-mono-${version}";
      url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/FantasqueSansMono.zip";
      stripRoot = false;

      postFetch = ''
        mkdir -p $out/share/{fonts/truetype,doc/${name}}
        mv $out/*.ttf $out/share/fonts/truetype
        mv $out/*.md $out/share/doc/${name}
      '';

      sha256 = "sha256-OW6b3f156RpLpAeKthvjMOXv/G5YeokHemLHIo2M2kw=";
    };
}
