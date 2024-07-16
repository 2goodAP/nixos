{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim.langtools;
  inherit (lib) mkIf;
in
  mkIf (builtins.elem "sql" cfg.languages && cfg.lsp.enable) {
    programs.neovim = {
      extraPackages = with pkgs; [sqls sqlfluff];

      extraLuaConfig = ''
        require("lspconfig").sqls.setup({
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
