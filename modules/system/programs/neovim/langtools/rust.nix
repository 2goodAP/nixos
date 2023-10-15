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
    mkIf (builtins.elem "rust" cfg.langtools.languages) (mkMerge [
      {
        environment.systemPackages =
          (
            optionals cfg.langtools.lsp.enable (with pkgs; [
              rust-analyzer
              vimPlugins.rust-tools-nvim
            ])
          )
          ++ (
            optionals cfg.langtools.dap.enable (with pkgs; [
              lldb
              vimPlugins.plenary-nvim
            ])
          );
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

          require('rust-tools').setup({
            server = {
              capabilities = capabilities,
              on_attach = function(_, bufnr)
                -- Hover actions
                vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, {buffer = bufnr})
                -- Code action groups
                vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, {buffer = bufnr})
              end,
            },
          })
        '';
      })
    ]);
}
