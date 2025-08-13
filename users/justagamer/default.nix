let
  uname = baseNameOf ./.;
in {
  users.users."${uname}" = {
    isNormalUser = true;
    initialPassword = "NixOS-${uname}.";
    createHome = true;
    extraGroups = [
      "disk"
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  home-manager.users."${uname}" = {inputs', ...}: {
    imports = [../common];

    tgap.home.desktop.gaming.enable = true;

    home.packages = [
      (inputs'.mint.packages.default.overrideAttrs (oldAttrs: {
        patches = oldAttrs.patches ++ [./patches/mint_fix_git_version_panic.patch];
      }))
    ];
  };
}
