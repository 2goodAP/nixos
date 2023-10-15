{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.tgap.system.programs.neovim.langtools;
    inherit (lib) mkIf mkMerge optionals;
  in
    mkIf (builtins.elem "lua" cfg.languages) (mkMerge [
      {
        environment.systemPackages = (
          optionals cfg.lsp.enable [pkgs.sumneko-lua-language-server]
        );
      }

      (mkIf cfg.lsp.enable {
        tgap.system.programs.neovim.luaExtraConfig = ''
          require('lspconfig').sumneko_lua.setup({
            settings = {
              Lua = {
                runtime = {
                  -- Tell the language server which version of Lua you're using
                  -- (most likely LuaJIT in the case of Neovim).
                  version = 'LuaJIT',
                },
                diagnostics = {
                  -- Get the language server to recognize the `vim` global.
                  globals = {'vim'},
                },
                workspace = {
                  -- Make the server aware of Neovim runtime files.
                  library = vim.api.nvim_get_runtime_file("", true),
                },
                -- Do not send telemetry data containing a
                -- randomized but unique identifier.
                telemetry = {
                  enable = false,
                },
              },
            },
          })
        '';
      })
    ]);
}
