{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim.langtools;
  inherit (lib) mkIf mkMerge optionals;

  vscode-js-debug = let
    version = "1.90.0";
  in
    pkgs.runCommand "vscode-js-debug" {
      nativeBuildInputs = [pkgs.coreutils];
    } ''
      mkdir -p $out
      cp -rt $out ${builtins.fetchTarball {
        url =
          "https://github.com/microsoft/vscode-js-debug/releases/download/"
          + "v${version}/js-debug-dap-v${version}.tar.gz";
        sha256 = "1r0s9669450sm27makzay45svx45b4byd6zicra7fccbr4rnhyqm";
      }}/*;
    '';
in
  mkIf (builtins.elem "typescript" cfg.languages) (mkMerge [
    {
      programs.neovim.extraPackages =
        optionals cfg.lsp.enable (with pkgs; [
          biome
          nodejs
          nodePackages.typescript-language-server
        ])
        ++ optionals cfg.dap.enable [vscode-js-debug];
    }

    (mkIf cfg.lsp.enable {
      programs.neovim.extraLuaConfig = ''
        require("lspconfig").tsserver.setup({
          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
          end,
        })

        require("conform").setup({
          formatters_by_ft = {
            javascript = {"biome-check", "biome"},
            javascriptreact = {"biome-check", "biome"},
            json = {"biome", "jq", stop_after_first = true},
            jsonc = {"biome", "jq", stop_after_first = true},
            typescript = {"biome-check", "biome"},
            typescriptreact = {"biome-check", "biome"},
          },
        })

        require("lint").linters_by_ft = {
          javascript = {"biome"},
          javascriptreact = {"biome"},
          json = {"biome"},
          jsonc = {"biome"},
          typescript = {"biome"},
          typescriptreact = {"biome"},
        }
      '';
    })

    (mkIf cfg.dap.enable {
      programs.neovim.extraLuaConfig = ''
        require("dap").adapters["pwa-node"] = {
          type = "server",
          host = "127.0.0.1",
          port = "''${port}",
          executable = {
            command = "node",
            -- Make sure to update this path to point to your installation
            args = {"${vscode-js-debug}/src/dapDebugServer.js", "''${port}"},
          }
        }

        for _, language in ipairs({"typescript", "javascript"}) do
          require("dap").configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "''${file}",
              cwd = "''${workspaceFolder}",
            },
          }
        end
      '';
    })
  ])
