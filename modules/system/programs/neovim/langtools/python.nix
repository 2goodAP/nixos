{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim;
  inherit (lib) mkIf mkMerge optionals;
in
  mkIf (builtins.elem "python" cfg.langtools.languages) (mkMerge [
    (mkIf cfg.langtools.lsp.enable {
      environment.systemPackages = [
        pkgs.ruff
        (pkgs.python3.withPackages (
          ps:
            (with ps; [
              bandit
              pylsp-mypy
              python-lsp-ruff
              python-lsp-server
              rope
              vulture
            ])
            ++ (optionals cfg.langtools.dap.enable [ps.debugpy])
        ))
      ];

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
          on_attach = on_attach,
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

        require('lint').linters_by_ft.python = {"bandit", "ruff", "vulture"}
      '';
    })

    (mkIf cfg.langtools.dap.enable {
      tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.nvim-dap-python];

      tgap.system.programs.neovim.luaExtraConfig = ''
        require("dap-python").setup("${pkgs.python3Packages.debugpy}/bin/python")
      '';
    })
  ])
