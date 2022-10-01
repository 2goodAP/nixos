{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.machine.programs.neovim.motion;
  inherit (lib) mkIf mkEnableOption;
in {
  options.machine.programs.neovim.motion = {
    enable = mkEnableOption "Whether or not to enable motion-related plugins.";

    comment.enable = mkEnableOpton "Whether or not to enable Comment.nvim.";

    harpoon.enable = mkEnableOpton "Whether or not to enable harpoon.";

    hop.enable = mkEnableOpton "Whether or not to enable hop.nvim.";

    surround.enable = mkEnableOpton "Whether or not to enable nvim-surround.";

    which-key.enable = mkEnableOpton "Whether or not to enable which-key.nvim";
  };

  config = mkIf cfg.enable {
    machine.programs.neovim.startPackages =
    (if cfg.comment.enable
      then [pkgs.vimPlugins.comment-nvim]
      else []
    ) ++ (if cfg.harpoon.enable
      then [pkgs.vimPlugins.plenary-nvim pkgs.vimPlugins.harpoon]
      else []
    ) ++ (if cfg.hop.enable
      then [pkgs.vimPlugins.hop-nvim]
      else []
    ) ++ (if cfg.surround.enable
      then [pkgs.vimPlugins.nvim-surround]
      else []
    ) ++ (if cfg.which-key.enable
      then [pkgs.vimPlugins.which-key-nvim]
      else []
    );

    machine.programs.neovim.luaConfig = let
      writeIf = cond: msg: if cond then msg else "";
    in ''
      ${writeIf cfg.comment.enable "require('Comment').setup()"}

      ${writeIf cfg.hop.enable "require('hop').setup()"}

      ${writeIf cfg.surround.enable "require('nvim-surround').setup()"}

      ${writeIf cfg.which-key.enable "require('which-key').setup()"}
    );
  };
}
