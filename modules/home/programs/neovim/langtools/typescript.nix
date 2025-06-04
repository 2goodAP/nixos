{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
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
  mkIf (
    cfg.enable && builtins.elem "typescript" cfg.langtools.languages
  ) (mkMerge [
    {
      programs.neovim.extraPackages =
        optionals cfg.langtools.lsp.enable (with pkgs; [
          biome
          nodejs
          typescript-language-server
        ])
        ++ optionals cfg.langtools.dap.enable [vscode-js-debug];
    }

    (mkIf cfg.langtools.lsp.enable {
      programs.neovim.extraLuaConfig = ''
        vim.lsp.enable("ts_ls")
        vim.lsp.config("ts_ls", {
          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
          end,
        })

        require("conform").setup({
          formatters = {
            ["biome-check"] = {
              args = {
                "check",
                "--indent-style",
                "space",
                "--write",
                "--stdin-file-path",
                "$FILENAME",
              },
            },
          },
          formatters_by_ft = {
            javascript = {"biome-check"},
            javascriptreact = {"biome-check"},
            json = {"biome-check", "jq", stop_after_first = true},
            jsonc = {"biome-check", "jq", stop_after_first = true},
            typescript = {"biome-check"},
            typescriptreact = {"biome-check"},
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

    (mkIf cfg.langtools.dap.enable {
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
