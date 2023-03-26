self: super: {
  libsForQt5 = super.libsForQt5.overrideScope' (final: prev: {
    sddm = prev.sddm.overrideAttrs (olds: let
      rev = "5fceaa9";
    in {
      pname = "sddm-git";
      version = "0.19.0.${rev}";

      src = super.fetchFromGitHub {
        owner = "sddm";
        repo = "sddm";
        inherit rev;
        sha256 = "sha256-vQnblh7uOo9gN4KuUmFYyOKcBnn2J6ZNho185iMhXPg=";
      };

      patches = [];

      cmakeFlags =
        olds.cmakeFlags
        ++ [
          "-DSYSTEMD_SYSUSERS_DIR=${placeholder "out"}/lib/sysusers.d"
          "-DSYSTEMD_TMPFILES_DIR=${placeholder "out"}/lib/tmpfiles.d"
        ];
    });
  });
}
