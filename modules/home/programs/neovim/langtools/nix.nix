{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim.langtools;
  inherit (lib) mkIf;
in
  mkIf (builtins.elem "nix" cfg.languages && cfg.lsp.enable) {
    programs.neovim = {
      extraPackages = with pkgs; [alejandra deadnix nixd];

      extraLuaConfig = ''
        require("lspconfig").nixd.setup({
          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
          end,
        })

        require("conform").setup({
          formatters_by_ft = {
            nix = {"alejandra"},
          },
        })

        require("lint").linters_by_ft.nix = {"nix", "deadnix"}
      '';
    };
  }
