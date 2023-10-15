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
    mkIf (builtins.elem "cpp" cfg.langtools.languages) (mkMerge [
      {
        environment.systemPackages =
          (
            optionals cfg.langtools.lsp.enable (with pkgs; [
              clang
              vimPlugins.clangd_extensions-nvim
            ])
          )
          ++ (
            optionals cfg.langtools.dap.enable [pkgs.lldb]
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

          -- Custom on_attach funciton for buffer-specific keybindings.
          local on_attach = function(client, bufnr)
          end

          require('lspconfig').clangd.setup({
            capabilities = capabilities,
            on_attach = on_attach,
          })
        '';
      })

      (mkIf cfg.langtools.dap.enable {
        tgap.system.programs.neovim.luaExtraConfig = ''
          local dap = require('dap')

          dap.adapters.lldb = {
            type = 'executable',
            command = '${pkgs.lldb}/bin/lldb-vscode', -- Must be absolute path
            name = 'lldb'
          }

          dap.configurations.cpp = {
            {
              name = 'Launch',
              type = 'lldb',
              request = 'launch',
              program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
              end,
              cwd = '$workspaceFolder',
              stopOnEntry = false,
              args = {},
            },
          }

          dap.configurations.c = dap.configurations.cpp
        '';
      })
    ]);
}
