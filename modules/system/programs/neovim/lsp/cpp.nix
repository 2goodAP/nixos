{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.programs.neovim.lsp.languages = let
    inherit (lib) mkEnableOption;
  in {
    cpp = mkEnableOption "Whether or not to enable cpp-specific lsp tools.";
  };

  config = let
    cfg = config.tgap.programs.neovim.lsp;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.languages.cpp) {
      environment.systemPackages = [pkgs.clang];

      tgap.programs.neovim.luaExtraConfig = ''
        require('lspconfig').clangd.setup()
      '';
    };
}
