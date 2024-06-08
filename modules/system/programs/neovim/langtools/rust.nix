{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim.langtools;
  inherit (lib) mkIf mkMerge optionals;
in
  mkIf (builtins.elem "rust" cfg.languages) (mkMerge [
    {
      environment.systemPackages =
        (optionals cfg.lsp.enable [pkgs.rustfmt])
        ++ (optionals cfg.dap.enable [pkgs.lldb]);

      tgap.system.programs.neovim.startPackages = optionals cfg.lsp.enable [
        pkgs.vimPlugins.rustaceanvim
      ];
    }

    (mkIf cfg.lsp.enable {
      tgap.system.programs.neovim.luaExtraConfig = ''
        require("conform").setup({
          formatters_by_ft = {
            rust = {"rustfmt"},
          },
        })
      '';

      programs.neovim.runtime."ftplugin/haskell.lua".text = ''
        local bufnr = vim.api.nvim_get_current_buf()

        vim.keymap.set(
          "n",
          "<leader>a",
          function()
            vim.cmd.RustLsp('codeAction') -- supports rust-analyzer's grouping
            -- or vim.lsp.buf.codeAction() if you don't want grouping.
          end,
          {silent = true, buffer = bufnr}
        )

        -- Default keymaps
        _set_lsp_keymaps(bufnr)
      '';
    })
  ])
