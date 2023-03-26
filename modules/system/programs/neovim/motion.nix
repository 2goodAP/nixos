{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.motion = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Whether or not to enable motion-related plugins.";

    comment.enable = mkEnableOption "Whether or not to enable Comment.nvim.";

    harpoon.enable = mkEnableOption "Whether or not to enable harpoon.";

    hop.enable = mkEnableOption "Whether or not to enable hop.nvim.";

    surround.enable = mkEnableOption "Whether or not to enable nvim-surround.";

    which-key.enable = mkEnableOption "Whether or not to enable which-key.nvim";
  };

  config = let
    cfg = config.tgap.system.programs.neovim.motion;
    inherit (lib) mkIf optionals;
  in
    mkIf cfg.enable {
      tgap.system.programs.neovim.startPackages =
        (
          optionals cfg.comment.enable [pkgs.vimPlugins.comment-nvim]
        )
        ++ (
          optionals
          cfg.harpoon.enable
          [pkgs.vimPlugins.plenary-nvim pkgs.vimPlugins.harpoon]
        )
        ++ (
          optionals cfg.hop.enable [pkgs.vimPlugins.hop-nvim]
        )
        ++ (
          optionals cfg.surround.enable [pkgs.vimPlugins.nvim-surround]
        )
        ++ (
          optionals cfg.which-key.enable [pkgs.vimPlugins.which-key-nvim]
        );

      tgap.system.programs.neovim.luaExtraConfig = let
        writeIf = cond: msg:
          if cond
          then msg
          else "";
      in ''
        ${writeIf cfg.comment.enable "require('Comment').setup()"}

        ${writeIf cfg.hop.enable "require('hop').setup()"}

        ${writeIf cfg.surround.enable "require('nvim-surround').setup()"}

        ${writeIf cfg.which-key.enable "require('which-key').setup()"}
      '';
    };
}
