{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim = let
    inherit (lib) mkEnableOption;
  in {
    statusline.enable = mkEnableOption "Whether or not to enable lualine.";
    tabline.enable = mkEnableOption "Whether or not to enable bufferline.";
  };

  config = let
    cfg = config.tgap.system.programs.neovim;
    inherit (lib) mkIf mkMerge;
    inherit (lib.strings) hasInfix optionalString;
  in
    mkMerge [
      (mkIf cfg.statusline.enable {
        tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.lualine-nvim];

        tgap.system.programs.neovim.luaExtraConfig = ''
          require("lualine").setup({
            options = {
              ${optionalString (hasInfix "tokyonight" cfg.colorscheme) "theme = tokyonight,"}
              icons_enabled = false,
              component_separators = "|",
              section_separators = "",
            }
          })
        '';
      })

      (mkIf cfg.tabline.enable {
        tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.bufferline-nvim];

        tgap.system.programs.neovim.luaExtraConfig = ''
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
      })
    ];
}
