{
  config,
  lib,
  pkgs,
  ...
}: {
  options.machine.programs.neovim.lsp.languages = let
    inherit (lib) mkEnableOption;
  in {
    typescript =
      mkEnableOption "Whether or not to enable typescript-specific lsp tools.";
  };

  config = let
    cfg = config.machine.programs.neovim.lsp;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.languages.typescript) {
      environment.systemPackages = [
        pkgs.nodejs
        pkgs.nodePackages.typescript-language-server
      ];

      machine.programs.neovim.luaConfig = ''
        require('lspconfig').tsserver.setup()
      '';
    };
}
