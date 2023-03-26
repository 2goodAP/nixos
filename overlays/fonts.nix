self: super: let
  version = "2.3.3";
in {
  caskaydia-cove-nerd-font = let
    name = "caskaydia-cove-nerd-font-${version}";
  in
    super.fetchzip {
      inherit name;
      url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/CascadiaCode.zip";

      stripRoot = false;

      postFetch = ''
        mkdir -p $out/share/{fonts/opentype,doc/${name}}
        mv $out/*.otf $out/share/fonts/opentype
        mv $out/*.md $out/share/doc/${name}
        mv $out/LICENSE* $out/share/doc/${name}
      '';

      sha256 = "sha256-Vgru3qJx/rSg1/96vJPb9YeAn9Og+cpr/u+l/WO+Z2o=";
    };

  fira-code-nerd-font = let
    name = "fira-code-nerd-font-${version}";
  in
    super.fetchzip {
      inherit name;
      url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/FiraCode.zip";

      stripRoot = false;

      postFetch = ''
        mkdir -p $out/share/{fonts/truetype,doc/${name}}
        mv $out/*.ttf $out/share/fonts/truetype
        mv $out/*.md $out/share/doc/${name}
        mv $out/LICENSE* $out/share/doc/${name}
      '';

      sha256 = "sha256-ZI6wq9svK+X90522ENIyG4S53G31IFYHXVTnb6/rHMM=";
    };

  noto-nerd-font = let
    name = "noto-nerd-font-${version}";
  in
    super.fetchzip {
      inherit name;
      url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/Noto.zip";

      stripRoot = false;

      postFetch = ''
        mkdir -p $out/share/{fonts/truetype,doc/${name}}
        mv $out/*.ttf $out/share/fonts/truetype
        mv $out/*.md $out/share/doc/${name}
        mv $out/LICENSE* $out/share/doc/${name}
      '';

      sha256 = "sha256-7sBU/k9W59duvKEtTbLQWwgyuFZuZSEqPPWudn2sFkk=";
    };
}
