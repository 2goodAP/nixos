{
  config,
  lib,
  options,
  pkgs,
  ...
}: {
  options.tgap.system.fonts = let
    inherit (lib) mkOption types;
  in {
    autohintFonts = mkOption {
      type = types.listOf types.str;
      default = [
        "Noto Sans"
        "Noto Sans Adlam"
        "Noto Sans Arabic UI"
        "Noto Sans Arabic"
        "Noto Sans Armenian"
        "Noto Sans Avestan"
        "Noto Sans Balinese"
        "Noto Sans Bamum"
        "Noto Sans Bassa Vah"
        "Noto Sans Batak"
        "Noto Sans Bengali"
        "Noto Sans Bhaiksuki"
        "Noto Sans Brahmi"
        "Noto Sans Buginese"
        "Noto Sans Buhid"
        "Noto Sans Canadian Aboriginal"
        "Noto Sans Carian"
        "Noto Sans Caucasian Albanian"
        "Noto Sans Chakma"
        "Noto Sans Cham"
        "Noto Sans Cherokee"
        "Noto Sans Coptic"
        "Noto Sans Cuneiform"
        "Noto Sans Cypriot"
        "Noto Sans Deseret"
        "Noto Sans Devanagari"
        "Noto Sans Duployan"
        "Noto Sans Elbasan"
        "Noto Sans Elymaic"
        "Noto Sans Ethiopic"
        "Noto Sans Georgian"
        "Noto Sans Glagolitic"
        "Noto Sans Gothic"
        "Noto Sans Grantha"
        "Noto Sans Gujarati"
        "Noto Sans Gunjala Gondi"
        "Noto Sans Gurmukhi"
        "Noto Sans Hanifi Rohingya"
        "Noto Sans Hanunoo"
        "Noto Sans Hatran"
        "Noto Sans Hebrew"
        "Noto Sans Javanese"
        "Noto Sans Kaithi"
        "Noto Sans Kannada"
        "Noto Sans Kayah Li"
        "Noto Sans Kharoshthi"
        "Noto Sans Khmer"
        "Noto Sans Khojki"
        "Noto Sans Khudawadi"
        "Noto Sans Lao"
        "Noto Sans Lepcha"
        "Noto Sans Limbu"
        "Noto Sans Linear A"
        "Noto Sans Linear B"
        "Noto Sans Lisu"
        "Noto Sans Lycian"
        "Noto Sans Lydian"
        "Noto Sans Mahajani"
        "Noto Sans Malayalam"
        "Noto Sans Mandaic"
        "Noto Sans Manichaean"
        "Noto Sans Marchen"
        "Noto Sans Masaram Gondi"
        "Noto Sans Mayan Numerals"
        "Noto Sans Medefaidrin"
        "Noto Sans Meetei Mayek"
        "Noto Sans Mende Kikakui"
        "Noto Sans Meroitic"
        "Noto Sans Miao"
        "Noto Sans Modi"
        "Noto Sans Mongolian"
        "Noto Sans Mro"
        "Noto Sans Multani"
        "Noto Sans Myanmar"
        "Noto Sans NKo"
        "Noto Sans Nabataean"
        "Noto Sans New Tai Lue"
        "Noto Sans Newa"
        "Noto Sans Nushu"
        "Noto Sans Ogham"
        "Noto Sans Ol Chiki"
        "Noto Sans Oriya"
        "Noto Sans Osage"
        "Noto Sans Osmanya"
        "Noto Sans Pahawh Hmong"
        "Noto Sans Palmyrene"
        "Noto Sans Pau Cin Hau"
        "Noto Sans PhagsPa"
        "Noto Sans Phoenician"
        "Noto Sans Rejang"
        "Noto Sans Runic"
        "Noto Sans Saurashtra"
        "Noto Sans Sharada"
        "Noto Sans Shavian"
        "Noto Sans Siddham"
        "Noto Sans Sinhala"
        "Noto Sans Sogdian"
        "Noto Sans Sora Sompeng"
        "Noto Sans Soyombo"
        "Noto Sans Sundanese"
        "Noto Sans Syloti Nagri"
        "Noto Sans Syriac"
        "Noto Sans Tagalog"
        "Noto Sans Tagbanwa"
        "Noto Sans Tai Le"
        "Noto Sans Tai Tham"
        "Noto Sans Tai Viet"
        "Noto Sans Tamil"
        "Noto Sans Takri"
        "Noto Sans Telugu"
        "Noto Sans Thaana"
        "Noto Sans Thai"
        "Noto Sans Tifinagh"
        "Noto Sans Tirhuta"
        "Noto Sans Ugaritic"
        "Noto Nastaliq Urdu"
        "Noto Sans Vai"
        "Noto Sans Wancho"
        "Noto Sans Warang Citi"
        "Noto Sans Yi"
        "Noto Sans Zanabazar Square"
        "Noto Sans Math"
        "Noto Sans Mono"
        "Noto Serif"
        "Noto Serif Ahom"
        "Noto Naskh Arabic"
        "Noto Serif Armenian"
        "Noto Serif Balinese"
        "Noto Serif Bengali"
        "Noto Serif Devanagari"
        "Noto Serif Dogra"
        "Noto Serif Ethiopic"
        "Noto Serif Georgian"
        "Noto Serif Grantha"
        "Noto Serif Gujarati"
        "Noto Serif Gurmukhi"
        "Noto Serif Hebrew"
        "Noto Serif Hmong Nyiakeng"
        "Noto Serif Kannada"
        "Noto Serif Khmer"
        "Noto Serif Khojki"
        "Noto Serif Lao"
        "Noto Serif Malayalam"
        "Noto Serif Myanmar"
        "Noto Serif Sinhala"
        "Noto Serif Tamil"
        "Noto Serif Tamil Slanted"
        "Noto Serif Tangut"
        "Noto Serif Telugu"
        "Noto Serif Thai"
        "Noto Serif Tibetan"
        "Noto Serif Yezidi"
      ];
      description = "The fonts for which to enable 'autohint' in fontconfig.";
    };
  };

  config = let
    cfg = config.tgap.system.fonts;
    inherit (lib) concatMapStrings;
  in {
    environment.systemPackages = with pkgs; [
      corefonts
      garamond-libre
      libertine
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      (nerdfonts.override {
        fonts = [
          "CascadiaCode"
          "JetBrainsMono"
          "Monaspace"
        ];
      })
    ];

    fonts.fontconfig = {
      cache32Bit = true;

      defaultFonts.monospace =
        [
          "JetBrainsMono Nerd Font"
          "Noto Sans Mono"
        ]
        ++ options.fonts.fontconfig.defaultFonts.monospace.default;

      localConf = let
        fc-20-autohint-fonts =
          concatMapStrings (font: ''
            <match target="pattern">
                <test name="family">
                    <string>${font}</string>
                </test>
                <edit mode="prepend" name="autohint">
                    <bool>true</bool>
                </edit>
            </match>
          '')
          cfg.autohintFonts;
      in ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <!-- 20-autohint-fonts.conf -->
          ${fc-20-autohint-fonts}

          <!-- 30-cjk-aliases.conf -->
          ${builtins.readFile ./fontconfig/30-cjk-aliases.conf}

          <!-- 56-language-selector-prefer.conf -->
          ${builtins.readFile ./fontconfig/56-language-selector-prefer.conf}

          <!-- 64-language-selector-cjk-prefer.conf -->
          ${builtins.readFile ./fontconfig/64-language-selector-cjk-prefer.conf}

          <!-- 70-fonts-noto-cjk-prefer.conf -->
          ${builtins.readFile ./fontconfig/70-fonts-noto-cjk.conf}
        </fontconfig>
      '';
    };
  };
}
