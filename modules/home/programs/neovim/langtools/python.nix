{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
  inherit (lib) mkIf mkMerge optionals;
in
  mkIf (cfg.enable && builtins.elem "python" cfg.langtools.languages) (mkMerge [
    {
      programs.neovim = {
        extraPackages = optionals cfg.langtools.lsp.enable (with pkgs; [
          ruff
          (python3.withPackages (ps:
            (with ps; [
              bandit
              mypy
              pylsp-mypy
              python-lsp-ruff
              python-lsp-server
              rope
              vulture
            ])
            ++ optionals cfg.langtools.dap.enable [ps.debugpy]))
        ]);
      };
    }

    (mkIf cfg.langtools.lsp.enable {
      programs.neovim.extraLuaConfig = ''
        -- Pylsp configuration
        vim.lsp.enable("pylsp")
        vim.lsp.config("pylsp", {
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

          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
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
      programs.neovim.plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-dap-python;
          type = "lua";
          config = "require('dap-python').setup('python')";
        }
      ];
    })
  ])
