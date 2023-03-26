{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.lsp.languages = let
    inherit (lib) mkEnableOption;
  in {
    typescript =
      mkEnableOption "Whether or not to enable typescript-specific lsp tools.";
  };

  config = let
    cfg = config.tgap.system.programs.neovim.lsp;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.languages.typescript) {
      environment.systemPackages = [
        pkgs.nodejs
        pkgs.nodePackages.typescript-language-server
      ];

      tgap.system.programs.neovim.luaExtraConfig = ''
        require('lspconfig').tsserver.setup()
      '';
    };
}
