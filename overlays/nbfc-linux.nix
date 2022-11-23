# An overlay for the latest version of nbfc-linux.
self: super: {
  nbfc-linux = super.stdenv.mkDerivation {
    name = "nbfc-linux";
    version = "20220918-git";

    src = super.fetchFromGitHub {
      owner = "nbfc-linux";
      repo = "nbfc-linux";
      rev = "0396c35";
      sha256 = "sha256-it24pt41yHYhcpfqnEaws7utoNxFFrH/HwBCD/9omkY=";
    };

    buildFlags = ["PREFIX=$(out)" "confdir=/etc"];

    installPhase = let
      installFlags = ["PREFIX=$out"];
    in ''
      make ${builtins.concatStringsSep " " installFlags}\
           install-core \
           install-client-c\
           install-configs\
           install-docs\
           install-completion
    '';
  };
}
