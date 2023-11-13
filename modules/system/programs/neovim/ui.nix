{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.ui.enable = let
    inherit (lib) mkEnableOption;
  in
    mkEnableOption "Whether or not to enable fancy ui for neovim.";

  config = let
    cfg = config.tgap.system.programs.neovim.ui;
    inherit (lib) mkIf optionals optionalString;
  in
    mkIf cfg.enable {
      tgap.system.programs.neovim.startPackages = with pkgs.vimPlugins; [
        dressing-nvim
        nvim-notify
      ];

      tgap.system.programs.neovim.luaExtraConfig = ''
        require("dressing").setup({})
        vim.notify = require("notify")
      '';
    };
}
