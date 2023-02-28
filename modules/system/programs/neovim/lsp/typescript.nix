{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.machine.programs.neovim.lsp;
  inherit (lib) mkIf mkEnableOption;
in {
  options.machine.programs.neovim.lsp.languages = {
    typescript =
      mkEnableOption "Whether or not to enable typescript-specific lsp tools.";
  };

  config = mkIf (cfg.enable && cfg.languages.typescript) {
    environment.systemPackages = [
      pkgs.nodejs
      pkgs.nodePackages.typescript-language-server
    ];

    machine.programs.neovim.luaConfig = ''
      require('lspconfig').tsserver.setup()
    '';
  };
}
