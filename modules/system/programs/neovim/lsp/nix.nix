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
    nix = mkEnableOption "Whether or not to enable nix-specific lsp tools.";
  };

  config = mkIf (cfg.enable && cfg.languages.nix) {
    environment.systemPackages = [pkgs.rnix-lsp];

    machine.programs.neovim.luaConfig = ''
      require('lspconfig').rnix.setup()
    '';
  };
}
