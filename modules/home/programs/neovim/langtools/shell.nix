{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs;
  osCfg = osConfig.tgap.system.programs;
  inherit (lib) getExe getExe' mkIf mkMerge optionals optionalString;
in
  mkIf (builtins.elem "shell" cfg.neovim.langtools.languages) (mkMerge [
    {
      programs.neovim.extraPackages =
        optionals cfg.neovim.langtools.lsp.enable (with pkgs; [
          dotenv-linter
          nodejs
          nodePackages.bash-language-server
          shellcheck
          shellharden
          shfmt
          vale
        ])
        ++ optionals cfg.neovim.langtools.dap.enable (with pkgs; [bashdb nodejs]);
    }

    (mkIf cfg.neovim.langtools.lsp.enable {
      programs.neovim.extraLuaConfig = ''
        vim.filetype.add({
          -- Detect and apply filetypes based on the entire filename
          filename = {
            [".env"] = "dotenv",
            ["env"] = "dotenv",
          },
          -- Detect and apply filetypes based on certain patterns of the filenames
          pattern = {
            -- INFO: Match filenames like - ".env.example", ".env.local" and so on
            ["%.env%.[%w_.-]+"] = "dotenv",
          },
        })

        require("lspconfig").bashls.setup({
          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
          end,
        })

        ${optionalString (osCfg.defaultShell == "nu") ''
          require("lspconfig").nushell.setup({
            capabilities = require("tgap.lsp-utils").capabilities,
            on_attach = function(client, bufnr)
              require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
            end,
          })
        ''}

        require("conform").setup({
          formatters_by_ft = {
            sh = {"shellharden", "shfmt"},
          },
        })

        require("lint").linters_by_ft = {
          dotenv = {"dotenv_linter"},
          sh = {"shellcheck"},
        }
      '';
    })

    (mkIf cfg.neovim.langtools.dap.enable {
      programs.neovim.extraLuaConfig = ''
        require("dap").adapters.bashdb = {
          type = "executable",
          command = "${getExe pkgs.bashdb}",
          name = "bashdb",
        }

        require("dap").configurations.sh = {
          {
            type = "bashdb",
            request = "launch",
            name = "Launch file",
            showDebugOutput = true,
            pathBashdb = "${getExe pkgs.bashdb}",
            pathBashdbLib = "${pkgs.bashdb}",
            trace = true,
            file = "''${file}",
            program = "''${file}",
            cwd = "''${workspaceFolder}",
            pathCat = "cat",
            pathBash = "${getExe' pkgs.bashInteractive "bash"}",
            pathMkfifo = "mkfifo",
            pathPkill = "pkill",
            args = {},
            env = {},
            terminalKind = "integrated",
          }
        }
      '';
    })
  ])
