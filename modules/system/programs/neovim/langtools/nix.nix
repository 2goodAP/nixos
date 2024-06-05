{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim;
  inherit (lib) mkIf;
in
  mkIf (builtins.elem "nix" cfg.langtools.languages && cfg.langtools.lsp.enable) {
    environment.systemPackages = [pkgs.nixd pkgs.alejandra];

    tgap.system.programs.neovim.luaExtraConfig = ''
      require("lspconfig").nixd.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      require("conform").setup({
        formatters_by_ft = {
          nix = {"alejandra"},
        },
      })

      require("lint").linters_by_ft.nix = {"nix"}
    '';
  }
