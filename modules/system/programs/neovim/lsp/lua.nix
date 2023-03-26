{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.lsp.languages = let
    inherit (lib) mkEnableOption;
  in {
    lua = mkEnableOption "Whether or not to enable lua-specific lsp tools.";
  };

  config = let
    cfg = config.tgap.system.programs.neovim.lsp;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.languages.lua) {
      environment.systemPackages = [pkgs.sumneko-lua-language-server];

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
    };
}
