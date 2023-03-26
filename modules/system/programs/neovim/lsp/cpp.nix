{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.lsp.languages = let
    inherit (lib) mkEnableOption;
  in {
    cpp = mkEnableOption "Whether or not to enable cpp-specific lsp tools.";
  };

  config = let
    cfg = config.tgap.system.programs.neovim.lsp;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.languages.cpp) {
      environment.systemPackages = [pkgs.clang];

      tgap.system.programs.neovim.luaExtraConfig = ''
        require('lspconfig').clangd.setup()
      '';
    };
}
