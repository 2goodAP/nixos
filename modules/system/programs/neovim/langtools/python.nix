{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim;
  inherit (lib) getExe mkIf mkMerge optionals;
in
  mkIf (builtins.elem "python" cfg.langtools.languages) (mkMerge [
    {
      environment.systemPackages = optionals cfg.langtools.lsp.enable (with pkgs; [
        mypy
        ruff
      ]);

      tgap.system.programs.neovim.python.extraPackageNames =
        [
          "bandit"
          "pylsp-mypy"
          "python-lsp-ruff"
          "python-lsp-server"
          "rope"
          "vulture"
        ]
        ++ (optionals cfg.langtools.dap.enable ["debugpy"]);
    }

    (mkIf cfg.langtools.lsp.enable {
      tgap.system.programs.neovim.luaExtraConfig = ''
        -- Pylsp configuration
        require("lspconfig").pylsp.setup({
          settings = {
            pylsp = {
              plugins = {
                autopep8 = {
                  enabled = false,
                },
                flake8 = {
                  enabled = false,
                },
                mccabe = {
                  enabled = false,
                },
                pycodestyle = {
                  enabled = false,
                },
                pyflakes = {
                  enabled = false,
                },
                pylint = {
                  enabled = false,
                },
                pylsp_mypy = {
                  enabled = true,
                  dmypy = true,
                  live_mode = false,
                  strict = false,
                },
                rope_completion = {
                  enabled = true,
                },
                ruff = {
                  enabled = true,
                },
                yapf = {
                  enabled = false,
                },
              }
            }
          },

          capabilities = capabilities,
          on_attach = function(client, bufnr)
            _set_lsp_keymaps(bufnr)
          end,
        })

        require("conform").setup({
          formatters_by_ft = {
            python = {
              "ruff_organize_imports",
              "ruff_fix",
              "ruff_format",
            },
          },
        })

        require('lint').linters_by_ft.python = {"ruff", "mypy", "vulture", "bandit"}
      '';
    })

    (mkIf cfg.langtools.dap.enable {
      tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.nvim-dap-python];

      tgap.system.programs.neovim.luaExtraConfig = ''
        require("dap-python").setup("${getExe cfg.python.package}")
      '';
    })
  ])
