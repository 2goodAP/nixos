{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
  inherit (lib) mkIf;
in
  mkIf (
    cfg.enable
    && builtins.elem "lua" cfg.langtools.languages
    && cfg.langtools.lsp.enable
  ) {
    programs.neovim = {
      extraPackages = with pkgs; [
        lua-language-server
        selene
        stylua
      ];

      extraLuaConfig = ''
        vim.lsp.enable("lua_ls")
        vim.lsp.config("lua_ls", {
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

          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
          end,
        })

        require("conform").setup({
          formatters_by_ft = {
            lua = {"stylua"},
          },
        })

        require("conform").formatters.stylua = {
          prepend_args = {
            "--column-width", "88",
            "--indent-type", "Spaces",
            "--indent-width", "2",
            "--sort-requires",
          },
        }

        require("lint").linters_by_ft.lua = {"selene"}
      '';
    };
  }
