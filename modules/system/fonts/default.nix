{
  options,
  pkgs,
  ...
}: let
  opts = options.fonts.fontconfig;
in {
  environment.systemPackages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "CascadiaCode"
        "JetBrainsMono"
        "Monaspace"
      ];
    })
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    cache32Bit = true;

    defaultFonts.monospace =
      [
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono"
      ]
      ++ opts.defaultFonts.monospace.default;

    localConf = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <!-- 30-cjk-aliases.conf -->
        ${builtins.readFile ./30-cjk-aliases.conf}

        <!-- 56-language-selector-prefer.conf -->
        ${builtins.readFile ./56-language-selector-prefer.conf}

        <!-- 64-language-selector-cjk-prefer.conf -->
        ${builtins.readFile ./64-language-selector-cjk-prefer.conf}

        <!-- 70-fongs-noto-cjk-prefer.conf -->
        ${builtins.readFile ./70-fonts-noto-cjk.conf}
      </fontconfig>
    '';
  };
}
