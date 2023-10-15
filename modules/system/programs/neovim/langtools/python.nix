{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.tgap.system.programs.neovim.langtools;
    inherit (lib) mkIf mkMerge optionals;
  in
    mkIf (builtins.elem "python" cfg.languages) (mkMerge [
      {
        environment.systemPackages =
          (
            optionals cfg.lsp.enable [
              (
                pkgs.python3.withPackages (pygs:
                  with pygs; [
                    bandit
                    pyls-isort
                    pylsp-mypy
                    python-lsp-black
                    python-lsp-server
                  ])
              )
            ]
          )
          ++ (
            optionals cfg.dap.enable [
              (pkgs.python3.withPackages (pygs: [pygs.debugpy]))
            ]
          );
      }

      (mkIf cfg.lsp.enable {
        tgap.system.programs.neovim.luaExtraConfig = ''
          -- Pylsp configuration
          require('lspconfig').pylsp.setup({
            settings = {
              pylsp = {
                plugins = {
                  autopep8 = {
                    enabled = false,
                  },
                  black = {
                    enabled = true,
                  },
                  flake8 = {
                    ignore = {E203, E501},
                    maxLineLength = 88, -- To be complient with Black.
                    select = {B950},
                  },
                  pylint = {
                    enabled = true,
                  },
                  pyls_isort = {
                    enabled = true,
                  },
                  pylsp_mypy = {
                    enabled = true,
                    dmypy = true,
                  },
                  rope_completion = {
                    enabled = true,
                  },
                  yapf = {
                    enabled = false,
                  },
                }
              }
            }
          })
        '';
      })

      (mkIf cfg.dap.enable {
        tgap.system.programs.neovim.luaExtraConfig = ''
          require('dap-python').setup('${pkgs.python3Packages.debugpy}/bin/python')
        '';
      })
    ]);
}
