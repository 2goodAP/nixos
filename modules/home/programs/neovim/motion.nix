{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.motion = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "motion-related plugins";
    harpoon.enable = mkEnableOption "harpoon";
    leap.enable = mkEnableOption "leap.nvim";
  };

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf optionals optionalString;
  in
    mkIf (cfg.enable && cfg.motion.enable) {
      programs.neovim.plugins =
        (with pkgs.vimPlugins; [
          {
            plugin = comment-nvim;
            type = "lua";
            config = "require('Comment').setup()";
          }
          {
            plugin = nvim-surround;
            type = "lua";
            config = "require('nvim-surround').setup()";
          }
          {
            plugin = which-key-nvim;
            type = "lua";
            config = ''
              vim.o.timeout = true
              vim.o.timeoutlen = 500
              require("which-key").setup({})
            '';
          }
        ])
        ++ optionals cfg.motion.harpoon.enable [
          pkgs.vimPlugins.plenary-nvim
          {
            plugin = pkgs.vimPlugins.harpoon;
            type = "lua";
            config = optionalString cfg.telescope.enable ''
              require("telescope").load_extension('harpoon')
            '';
          }
        ]
        ++ optionals cfg.motion.leap.enable (with pkgs.vimPlugins; [
          vim-repeat
          {
            plugin = leap-nvim;
            type = "lua";
            config = ''
              vim.keymap.set({'n', 'x', 'o'}, '<leader>s', '<Plug>(leap-forward)')
              vim.keymap.set({'n', 'x', 'o'}, '<leader>S', '<Plug>(leap-backward)')
              vim.keymap.set({'n', 'x', 'o'}, 'gs', '<Plug>(leap-from-window)')
            '';
          }
          {
            plugin = flit-nvim;
            type = "lua";
            config = "require('flit').setup()";
          }
        ]);
    };
}
