{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  inherit (lib) getExe;
in {
  programs.git = {
    enable = true;
    lfs.enable = true;
    extraConfig = {
      core.pager = "${getExe pkgs.delta}";
      delta.navigate = true;
      diff.colorMoved = "default";
      init.defaultBranch = "main";
      interactive.diffFilter = "${getExe pkgs.delta} --color-only";
      merge.conflictstyle = "diff3";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    extraConfig = "no-allow-external-cache";
    pinentryPackage =
      if (osConfig.tgap.system.desktop.manager == "plasma")
      then pkgs.pinentry-qt
      else pkgs.pinentry-gtk2;
  };

  home.packages = let
    nixgl = pkgs.nixgl.override {
      nvidiaVersion = "555.58.02";
      nvidiaHash = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
    };
  in
    [
      nixgl.auto.nixGLDefault
      nixgl.auto.nixVulkanNvidia
      nixgl.nixGLIntel
      nixgl.nixGLNvidia
      nixgl.nixVulkanIntel
    ]
    ++ (with pkgs; [
      aws-workspaces
      delta
      insomnia
      (nerdfonts.override {fonts = ["CascadiaCode" "JetBrainsMono" "Monaspace"];})
      openvpn
      slack
    ]);
}
