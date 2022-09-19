# An overlay for the latest version of Victor Mono Nerd Font.

self: super: {
  caskaydia-cove-nerd-font = let
    version = "2.2.2";
  in super.fetchzip rec {
    name = "caskaydia-cove-nerd-font-${version}";
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/CascadiaCode.zip";
    
    stripRoot = false;

    postFetch = ''
      mkdir -p $out/share/{fonts/opentype,doc/${name}}
      mv $out/*.otf $out/share/fonts/opentype
      mv $out/*.md $out/share/doc/${name}
      mv $out/LICENSE* $out/share/doc/${name}
    '';

    sha256 = "sha256-mKdhBsVeuvHhRG8RopcJQ6QDC25OMwUjs0S8Lw5LBzc=";
  };
}
