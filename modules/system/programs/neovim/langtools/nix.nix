{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.tgap.system.programs.neovim.langtools;
    inherit (lib) mkIf mkMerge optionals;
  in
    mkIf (builtins.elem "nix" cfg.languages) (mkMerge [
      {
        environment.systemPackages = (
          optionals cfg.lsp.enable [pkgs.rnix-lsp]
        );
      }

      (mkIf cfg.lsp.enable {
        tgap.system.programs.neovim.luaExtraConfig = ''
          require('lspconfig').rnix.setup()
        '';
      })
    ]);
}
