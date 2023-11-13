{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim.langtools;
  inherit (lib) mkIf mkMerge optionals;
in
  mkIf (builtins.elem "haskell" cfg.languages && cfg.lsp.enable) {
    environment.systemPackages =
      (with pkgs; [
        haskellPackages.haskell-language-server
        haskellPackages.hoogle
        vimPlugins.haskell-tools-nvim
      ])
      ++ (
        optionals cfg.dap.enable (with pkgs; [
          vimPlugins.plenary-nvim
          haskellPackages.haskell-debug-adapter
        ])
      );

    programs.neovim.runtime."ftplugin/haskell.lua".text = ''
      local ht = require("haskell-tools")
      local ht_opts = {
        noremap = true,
        silent = true,
        buffer = vim.api.nvim_get_current_buf(),
      }

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
    '';
  }
