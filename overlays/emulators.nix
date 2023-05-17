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

  ryujinx = super.ryujinx.overrideAttrs (olds: {
    version = "1.1.736";

    src = super.fetchFromGitHub {
      owner = "Ryujinx";
      repo = "Ryujinx";
      rev = "12504f280c1ab51b208d0eff8a60594e208315a2";
      sha256 = "sha256-KumaB6mojpzvByQVEHU5xTwdy4/DMEdJSb9Ha2TNk8w=";
    };

    testProjectFile = "src/Ryujinx.Tests/Ryujinx.Tests.csproj";
  });
}
