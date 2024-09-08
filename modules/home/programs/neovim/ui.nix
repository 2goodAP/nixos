{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.ui.enable = let
    inherit (lib) mkEnableOption;
  in
    mkEnableOption "fancy ui for neovim";

  config = let
    cfg = config.tgap.home.programs.neovim.ui;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      programs.neovim = {
        plugins = with pkgs.vimPlugins; [
          {
            plugin = dressing-nvim;
						type = "lua";
            config = "require('dressing').setup({})";
          }
          {
            plugin = indent-blankline-nvim;
						type = "lua";
            config = "require('ibl').setup()";
          }
          {
            plugin = nvim-notify;
						type = "lua";
            config = "vim.notify = require('notify')";
          }
        ];
      };
    };
}
