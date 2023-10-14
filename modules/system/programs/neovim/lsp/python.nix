{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.tgap.system.programs.neovim.lsp;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && (builtins.elem "python" cfg.languages)) {
      environment.systemPackages = [
        (
          pkgs.python3.withPackages (pygs: [
            pygs.bandit
            pygs.pyls-isort
            pygs.pylsp-mypy
            pygs.python-lsp-black
            pygs.python-lsp-server
          ])
        )
      ];

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
    };
}
