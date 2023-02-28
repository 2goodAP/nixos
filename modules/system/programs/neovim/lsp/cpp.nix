{
  config,
  lib,
  pkgs,
  ...
}: {
  options.machine.programs.neovim.lsp.languages = let
    inherit (lib) mkEnableOption;
  in {
    cpp = mkEnableOption "Whether or not to enable cpp-specific lsp tools.";
  };

  config = let
    cfg = config.machine.programs.neovim.lsp;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.languages.cpp) {
      environment.systemPackages = [pkgs.clang];

      machine.programs.neovim.luaConfig = ''
        require('lspconfig').clangd.setup()
      '';
    };
}
