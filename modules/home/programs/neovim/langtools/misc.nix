{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim.langtools;
  inherit (lib) mkIf mkMerge;
in
  mkMerge [
    (mkIf ((builtins.elem "hypr" cfg.languages) && cfg.lsp.enable) {
      programs.neovim = {
        extraPackages = [pkgs.hyprls];

        extraLuaConfig = ''
          require("lspconfig").hyprls.setup({})
        '';
      };
    })

    (mkIf (builtins.elem "lisp" cfg.languages) {
      programs.neovim.plugins = [pkgs.vimPlugins.parinfer-rust];
    })
  ]
