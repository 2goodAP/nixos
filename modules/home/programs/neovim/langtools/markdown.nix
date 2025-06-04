{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
  inherit (lib) mkIf;
in
  mkIf (
    cfg.enable
    && builtins.elem "markdown" cfg.langtools.languages
    && cfg.langtools.lsp.enable
  ) {
    programs.neovim = {
      extraPackages = with pkgs; [
        markdown-oxide
        markdownlint-cli2
      ];

      extraLuaConfig = ''
        vim.lsp.enable("markdown_oxide")
        vim.lsp.config("markdown_oxide", {
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
