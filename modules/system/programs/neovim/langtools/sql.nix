{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim;
  inherit (lib) mkIf;
in
  mkIf (builtins.elem "sql" cfg.langtools.languages && cfg.langtools.lsp.enable) {
    environment.systemPackages = [pkgs.sqls pkgs.sqlfluff];

    tgap.system.programs.neovim.luaExtraConfig = ''
      require("lspconfig").sqls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      require("conform").setup({
        formatters_by_ft = {
          sql = {"sqlfluff"},
        },
      })

      require("lint").linters_by_ft.sql = {"sqlfluff"}
    '';
  }
