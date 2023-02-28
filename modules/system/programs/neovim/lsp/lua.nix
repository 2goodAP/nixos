{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.machine.programs.neovim.lsp;
  inherit (lib) mkIf mkEnableOption;
in {
  options.machine.programs.neovim.lsp.languages = {
    lua = mkEnableOption "Whether or not to enable lua-specific lsp tools.";
  };

  config = mkIf (cfg.enable && cfg.languages.lua) {
    environment.systemPackages = [pkgs.sumneko-lua-language-server];

    machine.programs.neovim.luaConfig = ''
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
