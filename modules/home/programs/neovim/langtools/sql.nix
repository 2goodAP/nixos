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
    && builtins.elem "sql" cfg.langtools.languages
    && cfg.langtools.lsp.enable
  ) {
    programs.neovim = {
      extraPackages = with pkgs; [sqls sqlfluff];

      extraLuaConfig = ''
        vim.lsp.enable("sqls")
        vim.lsp.config("sqls", {
          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
          end,
        })

        require("conform").setup({
          formatters_by_ft = {
            sql = {"sqlfluff"},
          },
        })

        require("lint").linters_by_ft.sql = {"sqlfluff"}
      '';
    };
  }
