{
  config,
  lib,
  pkgs,
  ...
}: {
  options.machine.programs.neovim.lsp.languages = let
    inherit (lib) mkEnableOption;
  in {
    python = mkEnableOption "Whether or not to enable python-specific lsp tools.";
  };

  config = let
    cfg = config.machine.programs.neovim.lsp;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.languages.python) {
      environment.systemPackages = [
        pkgs.python3.withPackages
        (pygs: [
          pygs.bandit
          pygs.pyls-isort
          pygs.pylsp-mypy
          pygs.python-lsp-black
          pygs.python-lsp-server.override
          {
            withAutopep8 = false;
            withYapf = false;
          }
        ])
      ];

      machine.programs.neovim.luaConfig = ''
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
