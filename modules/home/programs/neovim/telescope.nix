{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.telescope.enable = let
    inherit (lib) mkEnableOption;
  in
    mkEnableOption "Whether or not to enable telescope.";

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf optionals;
  in
    mkIf cfg.telescope.enable {
      programs.neovim.plugins =
        (with pkgs.vimPlugins; [
          plenary-nvim
          {
            plugin = telescope-nvim;
            type = "lua";
            config = ''
              -- Define some sane mappings.
              vim.keymap.set(
                "n",
                "<leader>ff",
                "<cmd>lua require('telescope.builtin').find_files()<CR>",
                {desc = "Telescope find files."}
              )
              vim.keymap.set(
                "n",
                "<leader>fg",
                "<cmd>lua require('telescope.builtin').live_grep()<CR>",
                {desc = "Telescope live grep."}
              )
              vim.keymap.set(
                "n",
                "<leader>fb",
                "<cmd>lua require('telescope.builtin').buffers()<CR>",
                {desc = "Telescope find buffers."}
              )
              vim.keymap.set(
                "n",
                "<leader>fh",
                "<cmd>lua require('telescope.builtin').help_tags()<CR>",
                {desc = "Telescope find help tags."}
              )
            '';
          }
          {
            plugin = telescope-undo-nvim;
            type = "lua";
            config = ''
              require("telescope").load_extension("undo")
              vim.keymap.set(
                "n",
                "<leader>u",
                "<cmd>Telescope undo<cr>",
                {desc = "Telescope undo history."}
              )
            '';
          }
        ])
        ++ optionals cfg.langtools.dap.enable [
          {
            plugin = pkgs.vimPlugins.telescope-dap-nvim;
            type = "lua";
            config = "require('telescope').load_extension('dap')";
          }
        ];
    };
}
