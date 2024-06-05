{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim;
  inherit (lib) mkIf mkMerge optionals optionalString;
in
  mkIf (builtins.elem "lua" cfg.langtools.languages && cfg.langtools.lsp.enable) {
    environment.systemPackages = [pkgs.lua-language-server pkgs.stylua];

    tgap.system.programs.neovim.luaExtraConfig = ''
      require("lspconfig").lua_ls.setup({
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using
              -- (most likely LuaJIT in the case of Neovim).
              version = "LuaJIT",
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global.
              globals = {"vim"},
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

        capabilities = capabilities,
        on_attach = on_attach,
      })

      require("conform").setup({
        formatters_by_ft.lua = {"stylua"},
      })
    '';
  }
