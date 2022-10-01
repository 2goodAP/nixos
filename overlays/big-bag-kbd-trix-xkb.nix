# An overlay for the `BigBagKbdTrixXKB` repository by `DreymaR`.

self: super: {
  big-bag-kbd-trix-xkb = super.fetchFromGitHub {
    name = "big-bag-kbd-trix-xkb-20220731";
    owner = "DreymaR";
    repo = "BigBagKbdTrixXKB";
    rev = "a8db6e7";

    postFetch = ''
      mkdir -p $out/{bin,etc/X11,share/{doc,X11}}
      mv $out/*.sh $out/bin
      cp -r $out/xkb-data_xmod/xkb $out/etc/X11
      cp -r $out/xkb-data_xmod/xkb $out/share/X11
      mv $out/*.md $out/share/doc
      rm -r $out/[^bes]*
    '';

    sha256 = "sha256-s61Z2PeyS1Ml84jqnhvckggOOXVw8w9TZzmOs6TcPFA=";
  };
}
