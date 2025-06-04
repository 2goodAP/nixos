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
    && builtins.elem "r" cfg.langtools.languages
    && cfg.langtools.lsp.enable
  ) {
    programs.neovim = {
      extraPackages = with pkgs; [R rPackages.languageserver];

      extraLuaConfig = ''
        vim.lsp.enable("r_language_server")
        vim.lsp.config("r_language_server", {
          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
          end,
        })
      '';
    };
  }
