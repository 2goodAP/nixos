{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.tgap.system.programs.neovim;
    inherit (lib) mkIf mkMerge optionals;
  in
    mkIf (builtins.elem "typescript" cfg.langtools.languages) (mkMerge [
      {
        environment.systemPackages = optionals cfg.langtools.lsp.enable (with pkgs; [
          nodejs
          nodePackages.typescript-language-server
        ]);
      }

      (mkIf cfg.langtools.lsp.enable {
        tgap.system.programs.neovim.luaExtraConfig = let
          writeIfElse = cond: trueStr: falseStr:
            if cond
            then trueStr
            else falseStr;
        in ''
          ${
            writeIfElse cfg.autocompletion.enable ''
              -- Add additional capabilities supported by nvim-cmp.
              local capabilities = require("cmp_nvim_lsp").default_capabilities()
            '' ''
              -- Use standard Neovim lsp capabilities.
              local capabilities = vim.lsp.protocol.make_client_capabilities()
            ''
          }

          -- Custom on_attach funciton for buffer-specific keybindings.
          local on_attach = function(client, bufnr)
          end

          require('lspconfig').tsserver.setup({
            capabilities = capabilities,
            on_attach = on_attach,
          })
        '';
      })
    ]);
}
