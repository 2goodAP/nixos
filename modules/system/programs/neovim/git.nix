{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.git = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Whether or not to enable git-related plugins.";

    gitsigns.enable = mkEnableOption "Whether or not to enable gitsigns.";

    neogit.enable = mkEnableOption "Whether or not to enable neogit.";
  };

  config = let
    cfg = config.tgap.system.programs.neovim.git;
    inherit (lib) mkIf optionals;
    inherit (lib.strings) optionalString;
  in
    mkIf cfg.enable {
      tgap.system.programs.neovim.startPackages =
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

      tgap.system.programs.neovim.luaExtraConfig = ''
        ${optionalString cfg.neogit.enable "require('neogit').setup()"}

        ${optionalString cfg.gitsigns.enable "require('gitsigns').setup()"}
      '';
    };
}
