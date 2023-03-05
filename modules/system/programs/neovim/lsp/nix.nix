{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.programs.neovim.lsp.languages = let
    inherit (lib) mkEnableOption;
  in {
    nix = mkEnableOption "Whether or not to enable nix-specific lsp tools.";
  };

  config = let
    cfg = config.tgap.programs.neovim.lsp;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.languages.nix) {
      environment.systemPackages = [pkgs.rnix-lsp];

      tgap.programs.neovim.luaExtraConfig = ''
        require('lspconfig').rnix.setup()
      '';
    };
}
