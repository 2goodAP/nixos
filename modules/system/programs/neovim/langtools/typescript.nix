{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim.langtools;
  inherit (lib) getExe' mkIf mkMerge optionals;

  vscode-js-debug = let
    version = "1.90.0";
  in
    pkgs.runCommand "vscode-js-debug" {} ''
      ${getExe' pkgs.coreutils "mkdir"} -p $out
      ${getExe' pkgs.coreutils "cp"} -rt $out ${builtins.fetchTarball {
        url = "https://github.com/microsoft/vscode-js-debug/releases/download/v${version}/js-debug-dap-v${version}.tar.gz";
        sha256 = "1r0s9669450sm27makzay45svx45b4byd6zicra7fccbr4rnhyqm";
      }}/*;
    '';
in
  mkIf (builtins.elem "typescript" cfg.languages) (mkMerge [
    {
      environment.systemPackages =
        (optionals cfg.lsp.enable (with pkgs; [
          biome
          nodejs
          nodePackages.typescript-language-server
        ]))
        ++ (optionals cfg.dap.enable [vscode-js-debug]);
    }

    (mkIf cfg.lsp.enable {
      tgap.system.programs.neovim.luaExtraConfig = ''
        require("lspconfig").tsserver.setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            _set_lsp_keymaps(bufnr)
          end,
        })

        require("conform").setup({
          formatters_by_ft = {
            javascript = {{"biome-check", "biome"}},
            javascriptreact = {{"biome-check", "biome"}},
            json = {"biome", "jq"},
            jsonc = {"biome", "jq"},
            typescript = {{"biome-check", "biome"}},
            typescriptreact = {{"biome-check", "biome"}},
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
      tgap.system.programs.neovim.luaExtraConfig = ''
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
