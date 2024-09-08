{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim = let
    inherit (lib) mkEnableOption;
  in {
    statusline.enable = mkEnableOption "lualine";
    tabline.enable = mkEnableOption "bufferline";
  };

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf mkMerge;
    inherit (lib.strings) hasInfix optionalString;
  in
    mkMerge [
      (mkIf cfg.statusline.enable {
        programs.neovim.plugins = [
          {
            plugin = pkgs.vimPlugins.lualine-nvim;
            type = "lua";
            config = ''
              require("lualine").setup({
                options = {
                  ${optionalString (hasInfix "tokyonight" cfg.colorscheme) "theme = 'tokyonight',"}
                  ${optionalString (hasInfix "rose-pine" cfg.colorscheme) "theme = 'rose-pine',"}
                  icons_enabled = false,
                  component_separators = "|",
                  section_separators = "",
                }
              })
            '';
          }
        ];
      })

      (mkIf cfg.tabline.enable {
        programs.neovim.plugins = with pkgs.vimPlugins; [
          {
            plugin = bufferline-nvim;
            type = "lua";
            config = ''
              require("bufferline").setup({
                options = {
                  -- LSP Indicators
                  diagnostics_indicator = function(count, level, diagnostics_dict, context)
                    local s = " "
                    for e, n in pairs(diagnostics_dict) do
                      local sym = e == "error" and "x " or (e == "warning" and "o " or "i")
                      s = s .. n .. sym
                    end
                    return s
                  end,
                }
              })
            '';
          }
          {
            plugin = scope-nvim;
            type = "lua";
            config = ''
              require("scope").setup({})
              ${optionalString cfg.telescope.enable ''
                require("telescope").load_extension("scope")
              ''}
            '';
          }
        ];
      })
    ];
}
