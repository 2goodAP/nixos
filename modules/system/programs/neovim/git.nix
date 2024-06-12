{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.git.enable = let
    inherit (lib) mkEnableOption;
  in
    mkEnableOption "Whether or not to enable git-related plugins.";

  config = let
    cfg = config.tgap.system.programs.neovim.git;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      tgap.system.programs.neovim.startPackages = with pkgs.vimPlugins; [
        plenary-nvim
        neogit
        gitsigns-nvim
      ];

      tgap.system.programs.neovim.luaExtraConfig = ''
        require("neogit").setup()
        require("gitsigns").setup()
      '';
    };
}
