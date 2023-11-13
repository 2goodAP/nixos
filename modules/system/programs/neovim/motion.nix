{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.motion = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Whether or not to enable motion-related plugins.";
    harpoon.enable = mkEnableOption "Whether or not to enable harpoon.";
    leap.enable = mkEnableOption "Whether or not to enable leap.nvim.";
  };

  config = let
    cfg = config.tgap.system.programs.neovim.motion;
    inherit (lib) mkIf optionals optionalString;
  in
    mkIf cfg.enable {
      tgap.system.programs.neovim.startPackages =
        (with pkgs.vimPlugins; [comment-nvim nvim-surround which-key-nvim])
        ++ (
          optionals cfg.harpoon.enable [
            pkgs.vimPlugins.plenary-nvim
            pkgs.vimPlugins.harpoon
          ]
        )
        ++ (
          optionals cfg.leap.enable (with pkgs.vimPlugins; [
            vim-repeat
            leap-nvim
            flit-nvim
          ])
        );

      tgap.system.programs.neovim.luaExtraConfig = ''
        require("Comment").setup()
        require("nvim-surround").setup()

        vim.o.timeout = true
        vim.o.timeoutlen = 500
        require("which-key").setup({})

        ${optionalString cfg.leap.enable ''
          require("leap").add_default_mappings()
          require("flit").setup()
        ''}
      '';
    };
}
