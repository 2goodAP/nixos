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
      type = types.enum ["tokyonight" "rose-pine"];
      default = "rose-pine";
      description = "The colorscheme to use for neovim. Must be one of 'tokyonight'.";
    };

  config = let
    cfg = config.tgap.system.programs.neovim;
    inherit (lib) mkIf mkMerge;
  in
    mkMerge [
      (mkIf (cfg.colorscheme == "tokyonight") {
        tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.tokyonight-nvim];

        tgap.system.programs.neovim.luaExtraConfig = ''
          vim.cmd("colorscheme tokyonight")
        '';
      })

      (mkIf (cfg.colorscheme == "rose-pine") {
        tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.rose-pine];

        tgap.system.programs.neovim.luaExtraConfig = ''
          require("rose-pine").setup({
            dark_variant = "moon",
            dim_inactive_windows = true,
          })

          vim.cmd("colorscheme rose-pine")
        '';
      })
    ];
}
