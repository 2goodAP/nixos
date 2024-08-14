{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim.langtools;
  inherit (lib) mkIf mkMerge optionals;
in
  mkIf (builtins.elem "go" cfg.languages) (mkMerge [
    {
      programs.neovim = {
        plugins = optionals cfg.dap.enable [pkgs.vimPlugins.nvim-dap-go];

        extraPackages =
          optionals cfg.lsp.enable (with pkgs; [
            gofumpt
            goimports-reviser
            golangci-lint
            gopls
          ])
          ++ optionals cfg.dap.enable [pkgs.delve];
      };
    }

    (mkIf cfg.lsp.enable {
      programs.neovim.extraLuaConfig = ''
        require("lspconfig").sqls.setup({
          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
          end,
        })

        require("conform").setup({
          formatters_by_ft = {
            go = {"goimports-reviser", "gofumpt"},
          },
        })

        require("lint").linters_by_ft.go = {"golangcilint"}
      '';
    })

    (mkIf cfg.dap.enable {
      programs.neovim.extraLuaConfig = ''
        require("dap").adapters.delve = {
          type = "server",
          port = "''${port}",
          executable = {
            command = "dlv",
            args = {"dap", "-l", "127.0.0.1:''${port}"},
          }
        }

        -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
        require("dap").configurations.go = {
          {
            type = "delve",
            name = "Debug",
            request = "launch",
            program = "''${file}"
          },
          {
            type = "delve",
            name = "Debug test", -- configuration for debugging test files
            request = "launch",
            mode = "test",
            program = "''${file}"
          },
          -- works with go.mod packages and sub packages
          {
            type = "delve",
            name = "Debug test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./''${relativeFileDirname}",
          }
        }
      '';
    })
  ])
