{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs;
  inherit (lib) getExe getExe' mkIf mkMerge optionals optionalString;
in
  mkIf (builtins.elem "shell" cfg.neovim.langtools.languages) (mkMerge [
    {
      environment.systemPackages =
        (optionals cfg.neovim.langtools.lsp.enable (with pkgs; [
          dotenv-linter
          nodejs
          nodePackages.bash-language-server
          shellcheck
          shellharden
          shfmt
          vale
        ]))
        ++ (optionals (cfg.defaultShell == "nu") [pkgs.nufmt])
        ++ (optionals cfg.neovim.langtools.dap.enable [pkgs.bashdb pkgs.nodejs]);
    }

    (mkIf cfg.neovim.langtools.lsp.enable {
      tgap.system.programs.neovim.luaExtraConfig = ''
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
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            _set_lsp_keymaps(bufnr)
          end,
        })

        ${optionalString (cfg.defaultShell == "nu") ''
          require("lspconfig").nushell.setup({
            capabilities = capabilities,
            on_attach = on_attach,
          })
        ''}

        require("conform").setup({
          formatters_by_ft = {
            ${optionalString (cfg.defaultShell == "nu") ''nu = {"nufmt"},''}
            sh = {"shellharden", "shfmt"},
          },

        ${optionalString (cfg.defaultShell == "nu") ''
          formatters.nufmt = function(bufnr)
            return  {
              command = require("conform.util").find_executable({
                "${getExe pkgs.nufmt},
              }, "nufmt")
            },
          end,
        ''}
        })

        require("lint").linters_by_ft = {
          dotenv = {"dotenv_linter"},
          sh = {"shellcheck"},
        }
      '';
    })

    (mkIf cfg.neovim.langtools.dap.enable {
      tgap.system.programs.neovim.luaExtraConfig = ''
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
