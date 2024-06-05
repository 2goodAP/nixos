{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim;
  inherit (lib) mkIf mkMerge optionals optionalString;
in
  mkIf (builtins.elem "typescript" cfg.langtools.languages && cfg.langtools.lsp.enable) {
    environment.systemPackages =  with pkgs; [
      nodejs
      nodePackages.typescript-language-server
      prettierd
    ];

    tgap.system.programs.neovim.luaExtraConfig = ''
      require("lspconfig").tsserver.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      require("conform").setup({
        formatters_by_ft = {
          javascript = {{"prettierd", "prettier"}},
          typescript = {{"prettierd", "prettier"}},
        },
      })
    '';
  }
