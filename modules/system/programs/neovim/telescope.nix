{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.telescope = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Whether or not to enable telescope.";
  };

  config = let
    cfg = config.tgap.system.programs.neovim.telescope;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      tgap.system.programs.fd.enable = true;
      tgap.system.programs.ripgrep.enable = true;

      tgap.system.programs.neovim.startPackages = [
        pkgs.vimPlugins.plenary-nvim
        pkgs.vimPlugins.telescope
      ];

      tgap.system.programs.neovim.luaExtraConfig = ''
        -- Define some sane mappings.
        vim.keymap.set(
          'n',
          '<leader>ff',
          '<cmd>lua require('telescope.builtin').find_files()<CR>',
          {desc = 'Telescope find files.'}
        )
        vim.keymap.set(
          'n',
          '<leader>fg',
          '<cmd>lua require('telescope.builtin').live_grep()<CR>',
          {desc = 'Telescope live grep.'}
        )
        vim.keymap.set(
          'n',
          '<leader>fb',
          '<cmd>lua require('telescope.builtin').buffers()<CR>,
          {'desc = 'Telescope find buffers.'}
        )
        vim.keymap.set(
          'n',
          '<leader>fh',
          '<cmd>lua require('telescope.builtin').help_tags()<CR>,
          {'desc = 'Telescope find help tags.'}
        )
      '';
    };
}
