{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim.langtools;
  inherit (lib) mkIf;
in
  mkIf (builtins.elem "nix" cfg.languages && cfg.lsp.enable) {
    environment.systemPackages = [pkgs.alejandra pkgs.deadnix pkgs.nixd];

    tgap.system.programs.neovim.luaExtraConfig = ''
      require("lspconfig").nixd.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          _set_lsp_keymaps(bufnr)
        end,
      })

      require("conform").setup({
        formatters_by_ft = {
          nix = {"alejandra"},
        },
      })

      require("lint").linters_by_ft.nix = {"nix", "deadnix"}
    '';
  }
