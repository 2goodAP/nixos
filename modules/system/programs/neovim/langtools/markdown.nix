{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim;
  inherit (lib) mkIf;
in
  mkIf (builtins.elem "markdown" cfg.langtools.languages && cfg.langtools.lsp.enable) {
    environment.systemPackages = with pkgs; [
      markdown-oxide
      markdownlint-cli2
    ];

    tgap.system.programs.neovim.luaExtraConfig = ''
      require("lspconfig").markdown_oxide.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      require('lint').linters_by_ft.markdown = {"markdownlint-cli2", "vale"}
    '';
  }
