{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.machine.programs.neovim.git;
  inherit (lib) mkIf mkEnableOption optionals;
in {
  options.machine.programs.neovim.git = {
    enable = mkEnableOption "Whether or not to enable git-related plugins.";

    gitsigns.enable = mkEnableOpton "Whether or not to enable gitsigns.";

    neogit.enable = mkEnableOpton "Whether or not to enable neogit.";
  };

  config = mkIf cfg.enable {
    machine.programs.neovim.startPackages =
      (
        optionals cfg.neogit.enable [pkgs.vimPlugins.plenary-nvim pkgs.vimPlugins.harpoon]
      )
      ++ (
        optionals cfg.hop.enable [pkgs.vimPlugins.hop-nvim]
      )
      ++ (
        optionals cfg.surround.enable [pkgs.vimPlugins.nvim-surround]
      )
      ++ (
        optionals cfg.which-key.enable [pkgs.vimPlugins.which-key-nvim]
      );

    machine.programs.neovim.luaConfig = let
      writeIf = cond: msg:
        if cond
        then msg
        else "";
    in ''
      ${writeIf cfg.neogit.enable "require('neogit').setup()"}

      ${writeIf cfg.gitsigns.enable "require('gitsigns').setup()"}
    '';
  };
}
