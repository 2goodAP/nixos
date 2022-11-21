# An overlay for the latest version of Fira Code Nerd Font.

self: super: {
  fira-code-nerd-font = let
    version = "2.2.2";
  in
    super.fetchzip rec {
      name = "fira-code-nerd-font-${version}";
      url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/FiraCode.zip";

      stripRoot = false;

      postFetch = ''
        mkdir -p $out/share/{fonts/truetype,doc/${name}}
        mv $out/*.ttf $out/share/fonts/truetype
        mv $out/*.md $out/share/doc/${name}
        mv $out/LICENSE* $out/share/doc/${name}
      '';

      sha256 = "sha256-Woc/BRYzXP8ODudD/3LDn295Ba0yzfcJyVCoGxVYqgk=";
    };
}
