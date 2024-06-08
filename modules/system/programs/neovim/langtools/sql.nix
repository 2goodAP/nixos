{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim.langtools;
  inherit (lib) mkIf;
in
  mkIf (builtins.elem "sql" cfg.languages && cfg.lsp.enable) {
    environment.systemPackages = [pkgs.sqls pkgs.sqlfluff];

    tgap.system.programs.neovim.luaExtraConfig = ''
      require("lspconfig").sqls.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          _set_lsp_keymaps(bufnr)
        end,
      })

      require("conform").setup({
        formatters_by_ft = {
          sql = {"sqlfluff"},
        },
      })

      require("lint").linters_by_ft.sql = {"sqlfluff"}
    '';
  }
