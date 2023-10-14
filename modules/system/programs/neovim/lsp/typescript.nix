{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.tgap.system.programs.neovim.lsp;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && (builtins.elem "typescript" cfg.languages)) {
      environment.systemPackages = [
        pkgs.nodejs
        pkgs.nodePackages.typescript-language-server
      ];

      tgap.system.programs.neovim.luaExtraConfig = ''
        require('lspconfig').tsserver.setup()
      '';
    };
}
