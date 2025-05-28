{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
  inherit (lib) mkIf;
in
  mkIf ((builtins.elem "xml" cfg.langtools.languages) && cfg.langtools.lsp.enable) {
    programs.neovim = {
      extraPackages = with pkgs; [
        lemminx
        libxml2
      ];

      extraLuaConfig = ''
        require("lspconfig").lemminx.setup({
          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
          end,
        })

        require("conform").setup({
          formatters_by_ft = {
            xml = {"xmllint"},
          },
        })
      '';
    };
  }
