{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.git.enable = let
    inherit (lib) mkEnableOption;
  in
    mkEnableOption "git-related plugins";

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.git.enable) {
      programs.neovim = {
        plugins = with pkgs.vimPlugins; [
          plenary-nvim
          {
            plugin = neogit;
            type = "lua";
            config = "require('neogit').setup()";
          }
          {
            plugin = gitsigns-nvim;
            type = "lua";
            config = "require('gitsigns').setup()";
          }
        ];
      };
    };
}
