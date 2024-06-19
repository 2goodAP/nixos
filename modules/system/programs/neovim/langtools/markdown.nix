{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim.langtools;
  inherit (lib) mkIf;
in
  mkIf (builtins.elem "markdown" cfg.languages && cfg.lsp.enable) {
    environment.systemPackages = with pkgs; [
      markdown-oxide
      markdownlint-cli2
    ];

    tgap.system.programs.neovim.luaExtraConfig = ''
      require("lspconfig").markdown_oxide.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          _set_lsp_keymaps(bufnr)
        end,
      })

      require("conform").setup({
        formatters_by_ft = {
          markdown = {"typos"},
        },
      })

      require('lint').linters_by_ft.markdown = {"markdownlint-cli2", "vale"}
    '';
  }
