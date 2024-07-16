{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.colorscheme = let
    inherit (lib) mkOption types;
  in
    mkOption {
      type = types.enum ["tokyonight" "rose-pine"];
      default = "rose-pine";
      description = ''
        The colorscheme to use for neovim. Must be one of ['tokyonight', 'rose-pine'].";
      '';
    };

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf mkMerge;
  in
    mkMerge [
      (mkIf (cfg.colorscheme == "tokyonight") {
        programs.neovim.plugins = with pkgs.vimPlugins; [
          {
            plugin = tokyonight-nvim;
            type = "lua";
            config = "vim.cmd('colorscheme tokyonight')";
          }
        ];
      })

      (mkIf (cfg.colorscheme == "rose-pine") {
        programs.neovim.plugins = with pkgs.vimPlugins; [
          {
            plugin = rose-pine;
            type = "lua";
            config = ''
              require("rose-pine").setup({
                dark_variant = "moon",
                dim_inactive_windows = true,
              })

              vim.cmd("colorscheme rose-pine")
            '';
          }
        ];
      })
    ];
}
