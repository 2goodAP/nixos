{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim.langtools;
  inherit (lib) mkIf mkMerge optionals;
in
  mkIf (builtins.elem "go" cfg.languages) (mkMerge [
    {
      environment.systemPackages =
        (optionals cfg.lsp.enable (with pkgs; [
          gofumpt
          goimports-reviser
          golangci-lint
          gopls
        ]))
        ++ (optionals cfg.dap.enable [pkgs.delve]);

      tgap.system.programs.neovim.startPackages = optionals cfg.dap.enable [
        pkgs.vimPlugins.nvim-dap-go
      ];
    }

    (mkIf cfg.lsp.enable {
      tgap.system.programs.neovim.luaExtraConfig = ''
        require("lspconfig").sqls.setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            _set_lsp_keymaps(bufnr)
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
      tgap.system.programs.neovim.luaExtraConfig = ''
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
