{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.colorscheme = let
    inherit (lib) mkOption types;
  in
    mkOption {
      type = types.enum ["tokyonight"];
      default = "tokyonight";
      description = "The colorscheme to use for neovim. Must be one of 'tokyonight'.";
    };

  config = let
    cfg = config.tgap.system.programs.neovim;
    inherit (lib) mkIf;
  in
    mkIf (cfg.colorscheme == "tokyonight") {
      tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.tokyonight-nvim];

      tgap.system.programs.neovim.luaExtraConfig = ''
        vim.cmd([[colorscheme tokyonight]])
      '';
    };
}
