{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.filetype = let
    inherit (lib) mkEnableOption;
  in {
    editorconfig.enable = mkEnableOption "Whether or not to enable editorconfig.nvim.";
    glow.enable = mkEnableOption "Whether or not to enable glow.nvim.";
    neorg.enable = mkEnableOption "Whether or not to enable neorg.";
  };

  config = let
    cfg = config.tgap.system.programs.neovim;
    inherit (lib) mkIf mkMerge optionals optionalString;
  in
    mkMerge [
      (mkIf cfg.filetype.glow.enable {
        tgap.system.programs.glow.enable = true;
        tgap.system.programs.neovim.optPackages = [pkgs.vimPlugins.glow-nvim];

        tgap.system.programs.neovim.luaExtraConfig = ''
          vim.api.nvim_create_augroup("MarkdownGroup", {clear = true})
          vim.api.nvim_create_autocmd(
            {"BufNewFile", "BufRead", "BufEnter", "BufWinEnter"},
            {
              pattern = {"*.md"},
              callback = function()
                vim.cmd("packadd glow.nvim")
                require("glow").setup({
                  glow_path = "${pkgs.glow}/bin/glow",
                })
              end,
              group = "MarkdownGroup"
            }
          )
        '';
      })

      (mkIf cfg.filetype.editorconfig.enable {
        tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.editorconfig-nvim];
      })

      (mkIf cfg.filetype.neorg.enable {
        tgap.system.programs.neovim.startPackages =
          (with pkgs.luajitPackages; [
            lua-utils-nvim
            pathlib-nvim
            rocks-nvim
          ])
          ++ (with pkgs.vimPlugins; [
            nui-nvim
            nvim-nio
            plenary-nvim
          ]);

        tgap.system.programs.neovim.optPackages =
          [pkgs.vimPlugins.neorg]
          ++ (
            optionals cfg.telescope.enable [pkgs.vimPlugins.neorg-telescope]
          );

        tgap.system.programs.neovim.luaExtraConfig = ''
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
      })
    ];
}
