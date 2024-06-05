{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim;
  inherit (lib) mkIf;
in
  mkIf (builtins.elem "typescript" cfg.langtools.languages && cfg.langtools.lsp.enable) {
    environment.systemPackages = with pkgs; [
      biome
      nodejs
      nodePackages.typescript-language-server
    ];

    tgap.system.programs.neovim.luaExtraConfig = ''
      require("lspconfig").tsserver.setup({
        capabilities = capabilities,
        on_attach = on_attach,
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
  }
