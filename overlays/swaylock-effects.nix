# An overlay for the latest version of swaylock-effects from a different maintainer.
self: super: {
  swaylock-effects = super.swaylock-effects.overrideAttrs (oldAttrs: {
    version = "1.6.10";

    src = super.fetchFromGitHub {
      owner = "jirutka";
      repo = "swaylock-effects";
      rev = "4b54b85d964243eef8d77ea0505eed728c62387f";
      sha256 = "sha256-QvMnJ5/uL/DvBhP9kagZJh9vwXBF2sCw3HWkfI4FDH0=";
    };
  });
}
