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
    && builtins.elem "nix" cfg.langtools.languages
    && cfg.langtools.lsp.enable
  ) {
    programs.neovim = {
      extraPackages = with pkgs; [alejandra deadnix nixd];

      extraLuaConfig = ''
        vim.lsp.enable("nixd")
        vim.lsp.config("nixd", {
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
