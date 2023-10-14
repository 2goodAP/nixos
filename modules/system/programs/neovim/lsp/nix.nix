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
    mkIf (cfg.enable && (builtins.elem "nix" cfg.languages)) {
      environment.systemPackages = [pkgs.rnix-lsp];

      tgap.system.programs.neovim.luaExtraConfig = ''
        require('lspconfig').rnix.setup()
      '';
    };
}
