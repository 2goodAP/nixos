{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.machine.programs.neovim.git;
  inherit (lib) mkIf mkEnableOption;
in {
  options.machine.programs.neovim.git = {
    enable = mkEnableOption "Whether or not to enable git-related plugins.";

    gitsigns.enable = mkEnableOpton "Whether or not to enable gitsigns.";

    neogit.enable = mkEnableOpton "Whether or not to enable neogit.";
  };

  config = mkIf cfg.enable {
    machine.programs.neovim.startPackages =
    (if cfg.neogit.enable
      then [pkgs.vimPlugins.plenary-nvim pkgs.vimPlugins.harpoon]
      else []
    ) ++ (if cfg.hop.enable
      then [pkgs.vimPlugins.hop-nvim]
      else []
    ) ++ (if cfg.surround.enable
      then [pkgs.vimPlugins.nvim-surround]
      else []
    ) ++ (if cfg.which-key.enable
      then [pkgs.vimPlugins.which-key-nvim]
      else []
    );

    machine.programs.neovim.luaConfig = let
      writeIf = cond: msg: if cond then msg else "";
    in ''
      ${writeIf cfg.neogit.enable "require('neogit').setup()"}

      ${writeIf cfg.gitsigns.enable "require('gitsigns').setup()"}
    '';
  };
}
