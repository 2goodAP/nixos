self: super: {
  citra-nightly = let
    version = "1904";
  in
    (super.citra-nightly.override {
      libsForQt5 = self.qt6Packages;
    })
    .overrideAttrs (olds: {
      inherit version;

      src = super.fetchFromGitHub {
        owner = "citra-emu";
        repo = "citra-nightly";
        rev = "nightly-${version}";
        sha256 = "sha256-N/iUjlHfWHhq2hp0YYFg7Orf1h7zZhJOjhsS11S1TdQ=";
        fetchSubmodules = true;
      };

      cmakeFlags =
        olds.cmakeFlags
        ++ [
          "-DCMAKE_INSTALL_INCLUDEDIR=include"
          "-DCMAKE_INSTALL_LIBDIR=lib"
        ];
    });
}
