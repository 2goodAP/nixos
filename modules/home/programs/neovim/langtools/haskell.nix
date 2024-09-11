{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
  inherit (lib) mkIf mkMerge optionals;
in
  mkIf (builtins.elem "haskell" cfg.langtools.languages) (mkMerge [
    {
      programs.neovim = {
        plugins =
          optionals cfg.langtools.lsp.enable [pkgs.vimPlugins.haskell-tools-nvim];

        extraPackages =
          optionals cfg.langtools.lsp.enable (with pkgs.haskellPackages; [
            cabal-fmt
            ghci-dap
            haskell-language-server
            hlint
            hoogle
          ])
          ++ optionals cfg.langtools.dap.enable (with pkgs; [
            haskellPackages.haskell-debug-adapter
          ]);
      };
    }

    (mkIf cfg.langtools.lsp.enable {
      home.file."${cfg.runtimepath}/ftplugin/haskell.lua".text = ''
        local ht = require("haskell-tools")
        local bufnr = vim.api.nvim_get_current_buf()
        local ht_opts = {noremap = true, silent = true, buffer = bufnr}

        -- haskell-language-server relies heavily on codelenses,
        -- so auto-refresh (see advanced configuration) is enabled by default
        vim.keymap.set("n", "<space>ca", vim.lsp.codelens.run, ht_opts)

        -- Hoogle search for the type signature of the definition under the cursor
        vim.keymap.set("n", "<space>hs", ht.hoogle.hoogle_signature, ht_opts)

        -- Evaluate all code snippets
        vim.keymap.set("n", "<space>ea", ht.lsp.buf_eval_all, ht_opts)

        -- Toggle a GHCi repl for the current package
        vim.keymap.set("n", "<leader>rr", ht.repl.toggle, ht_opts)

        -- Toggle a GHCi repl for the current buffer
        vim.keymap.set("n", "<leader>rf", function()
          ht.repl.toggle(vim.api.nvim_buf_get_name(0))
        end, ht_opts)
        vim.keymap.set("n", "<leader>rq", ht.repl.quit, ht_opts)

        -- Default keymaps
        require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
      '';

      programs.neovim.extraLuaConfig = ''
        require("conform").setup({
          formatters_by_ft = {
            cabal = {"cabal_fmt"},
          },
        })

        require("lint").linters_by_ft.haskell = {"hlint"}
      '';
    })
  ])
