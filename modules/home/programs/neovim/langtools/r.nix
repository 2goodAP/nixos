{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim.langtools;
  inherit (lib) mkIf;
in
  mkIf (builtins.elem "r" cfg.languages && cfg.lsp.enable) {
    programs.neovim = {
      extraPackages = with pkgs; [R rPackages.languageserver];

      extraLuaConfig = ''
        require("lspconfig").r_language_server.setup({
          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
          end,
        })
      '';
    };
  }
