{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.programs.neovim.git = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Whether or not to enable git-related plugins.";

    gitsigns.enable = mkEnableOption "Whether or not to enable gitsigns.";

    neogit.enable = mkEnableOption "Whether or not to enable neogit.";
  };

  config = let
    cfg = config.tgap.programs.neovim.git;
    inherit (lib) mkIf optionals;
  in
    mkIf cfg.enable {
      tgap.programs.neovim.startPackages =
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

      tgap.programs.neovim.luaExtraConfig = let
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
