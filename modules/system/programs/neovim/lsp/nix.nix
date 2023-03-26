{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.lsp.languages = let
    inherit (lib) mkEnableOption;
  in {
    nix = mkEnableOption "Whether or not to enable nix-specific lsp tools.";
  };

  config = let
    cfg = config.tgap.system.programs.neovim.lsp;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.languages.nix) {
      environment.systemPackages = [pkgs.rnix-lsp];

      tgap.system.programs.neovim.luaExtraConfig = ''
        require('lspconfig').rnix.setup()
      '';
    };
}
