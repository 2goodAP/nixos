{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
  inherit (lib) mkIf mkMerge optionals;
in
  mkIf (builtins.elem "rust" cfg.langtools.languages) (mkMerge [
    {
      programs.neovim = {
        plugins = optionals cfg.langtools.lsp.enable [pkgs.vimPlugins.rustaceanvim];

        extraPackages =
          (optionals cfg.langtools.lsp.enable [pkgs.rustfmt])
          ++ (optionals cfg.langtools.dap.enable [pkgs.lldb]);
      };
    }

    (mkIf cfg.langtools.lsp.enable {
      home.file."${cfg.runtimepath}/ftplugin/rust.lua".text = ''
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
        require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
      '';

      programs.neovim.extraLuaConfig = ''
        require("conform").setup({
          formatters_by_ft = {
            rust = {"rustfmt"},
          },
        })
      '';
    })
  ])
