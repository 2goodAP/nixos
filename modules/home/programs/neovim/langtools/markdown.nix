{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim.langtools;
  inherit (lib) mkIf;
in
  mkIf (builtins.elem "markdown" cfg.languages && cfg.lsp.enable) {
    programs.neovim = {
      extraPackages = with pkgs; [
        markdown-oxide
        markdownlint-cli2
      ];

      extraLuaConfig = ''
        require("lspconfig").markdown_oxide.setup({
          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
          end,
        })

        require("conform").setup({
          formatters_by_ft = {
            markdown = {"typos"},
          },
        })

        require('lint').linters_by_ft.markdown = {"markdownlint-cli2", "vale"}
      '';
    };
  }
