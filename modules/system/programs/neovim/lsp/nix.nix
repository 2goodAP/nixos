{
  config,
  lib,
  pkgs,
  ...
}: {
  options.machine.programs.neovim.lsp.languages = let
    inherit (lib) mkEnableOption;
  in {
    nix = mkEnableOption "Whether or not to enable nix-specific lsp tools.";
  };

  config = let
    cfg = config.machine.programs.neovim.lsp;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.languages.nix) {
      environment.systemPackages = [pkgs.rnix-lsp];

      machine.programs.neovim.luaConfig = ''
        require('lspconfig').rnix.setup()
      '';
    };
}
