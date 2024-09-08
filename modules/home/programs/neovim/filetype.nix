{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.filetype = let
    inherit (lib) mkEnableOption;
  in {
    editorconfig.enable = mkEnableOption "editorconfig.nvim";
    glow.enable = mkEnableOption "glow.nvim";
    neorg.enable = mkEnableOption "neorg";
  };

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf mkMerge optionalString;
  in
    mkMerge [
      (mkIf cfg.filetype.glow.enable {
        programs.neovim = {
          extraPackages = [pkgs.glow];

          plugins = with pkgs; [
            {
              optional = true;
              plugin = vimPlugins.glow-nvim;
              type = "lua";
              config = ''
                vim.api.nvim_create_augroup("MarkdownGroup", {clear = true})
                vim.api.nvim_create_autocmd(
                  {"BufNewFile", "BufRead", "BufEnter", "BufWinEnter"},
                  {
                    pattern = {"*.md"},
                    callback = function()
                      vim.cmd("packadd glow.nvim")
                      require("glow").setup({
                        glow_path = "${glow}/bin/glow",
                      })
                    end,
                    group = "MarkdownGroup"
                  }
                )
              '';
            }
          ];
        };
      })

      (mkIf cfg.filetype.editorconfig.enable {
        programs.neovim.plugins = [pkgs.vimPlugins.editorconfig-nvim];
      })

      (mkIf cfg.filetype.neorg.enable {
        programs.neovim = {
          extraLuaPackages = luaPkgs:
            with luaPkgs; [
              lua-utils-nvim
              pathlib-nvim
              rocks-nvim
            ];

          plugins =
            (with pkgs.vimPlugins; [
              neorg-telescope
              nui-nvim
              nvim-nio
              plenary-nvim
            ])
            ++ [
              {
                optional = true;
                plugin = pkgs.vimPlugins.neorg;
							  type = "lua";
                config = ''
                  vim.api.nvim_create_augroup("NeorgGroup", {clear = true})
                  vim.api.nvim_create_autocmd(
                    {"BufNewFile", "BufRead", "BufEnter", "BufWinEnter"},
                    {
                      pattern = {"*.norg"},
                      callback = function()
                        vim.cmd("packadd neorg")
                        ${optionalString cfg.telescope.enable "vim.cmd('packadd neorg-telescope')"}
                        require('neorg').setup({
                          load = {
                            ["core.defaults"] = {}, -- Loads default behaviour
                            ["core.concealer"] = {}, -- Adds pretty icons to your documents
                            ["core.dirman"] = {}, -- Manages Neorg workspaces
                            ${optionalString cfg.telescope.enable "['core.integrations.telescope'] = {},"}
                          },
                        })
                      end,
                      group = "NeorgGroup"
                    }
                  )
                '';
              }
            ];
        };
      })
    ];
}
