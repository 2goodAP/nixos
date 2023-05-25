self: super: {
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
