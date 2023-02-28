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
    cpp = mkEnableOption "Whether or not to enable cpp-specific lsp tools.";
  };

  config = mkIf (cfg.enable && cfg.languages.cpp) {
    environment.systemPackages = [pkgs.clang];

    machine.programs.neovim.luaConfig = ''
      require('lspconfig').clangd.setup()
    '';
  };
}
