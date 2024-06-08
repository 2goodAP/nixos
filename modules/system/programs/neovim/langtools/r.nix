{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim.langtools;
  inherit (lib) mkIf;
in
  mkIf (builtins.elem "r" cfg.languages && cfg.lsp.enable) {
    environment.systemPackages = [pkgs.R pkgs.rPackages.languageserver];

    tgap.system.programs.neovim.luaExtraConfig = ''
      require("lspconfig").r_language_server.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          _set_lsp_keymaps(bufnr)
        end,
      })
    '';
  }
