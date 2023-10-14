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
    mkIf (cfg.enable && (builtins.elem "cpp" cfg.languages)) {
      environment.systemPackages = [pkgs.clang];

      tgap.system.programs.neovim.luaExtraConfig = ''
        require('lspconfig').clangd.setup()
      '';
    };
}
