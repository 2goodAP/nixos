{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim = let
    inherit (lib) mkEnableOption;
  in {
    statusline.enable = mkEnableOption "lualine" // {default = true;};
    tabline.enable = mkEnableOption "bufferline" // {default = true;};
  };

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf mkMerge optionalString;
  in
    mkIf cfg.enable (mkMerge [
      (mkIf cfg.statusline.enable {
        programs.neovim.plugins = with pkgs.vimPlugins; [
          mini-icons
          nvim-web-devicons
          {
            plugin = lualine-nvim;
            optional = true;
            type = "lua";
            config = ''
              require("lz.n").load({
                "lualine.nvim",
                event = "DeferredUIEnter",
                after = function()
                  local lualine = require("lualine")

                  lualine.setup({
                    options = {
                      component_separators = "|",
                      section_separators = "",
                      disabled_filetypes = {
                        statusline = {${optionalString cfg.ui.enable ''"neo-tree"''}},
                      },
                    },
                  })
                  table.insert(
                    lualine.get_config().sections.lualine_x,
                    Snacks.profiler.status()
                  )
                end,
              })
            '';
          }
        ];
      })

      (mkIf cfg.tabline.enable {
        programs.neovim.plugins = with pkgs.vimPlugins; [
          {
            plugin = scope-nvim;
            type = "lua";
            config = ''
              require("lz.n").load({
                "scope.nvim",
                lazy = false,
                after = function()
                  require("scope").setup({})

                  vim.keymap.set(
                    "n", "<leader>bt", "<Cmd>ScopeMoveBuf<CR>",
                    {desc = "Move current buffer to the specified tab"}
                  )
                end,
              })
            '';
          }

          mini-icons
          nvim-web-devicons
          {
            plugin = bufferline-nvim;
            optional = true;
            type = "lua";
            config = ''
              require("lz.n").load({
                "bufferline.nvim",
                event = "DeferredUIEnter",
                after = function()
                  local function bufdel(bufnr)
                    Snacks.bufdelete(bufnr)
                  end

                  require("bufferline").setup({
                    options = {
                      diagnostics = "nvim_lsp",
                      close_command = bufdel,
                      right_mouse_command = bufdel,
                      middle_mouse_command = function(bufnr)
                        Snacks.rename.rename_file({
                          from = vim.api.nvim_buf_get_name(bufnr),
                        })
                      end,
                      diagnostics_indicator = function(count, level, diag_dict, context)
                        if context.buffer:current() then
                          return ""
                        end

                        local indicator = " "
                        for lvl, cnt in pairs(diag_dict) do
                          local icon = lvl == "error" and "  "
                            or (lvl == "warning" and "  "
                              or (lvl == "info" and "  " or "󰌵 "))
                          indicator = indicator .. cnt .. icon
                        end

                        return indicator
                      end,
                      offsets = {
              ${
                optionalString cfg.ui.enable ''
                  {
                    filetype = "neo-tree",
                    text = "Neo-tree",
                    text_align = "center",
                    separator = true,
                  },
                ''
              }
                      },
                      hover = {
                        enabled = true,
                        delay = 200,
                        reveal = {"close"},
                      },
                    },
                  })

                  local bl_opts = {silent = true}

                  vim.keymap.set(
                    "n", "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine close all left buffers"})
                  )

                  vim.keymap.set(
                    "n", "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine close all other buffers"})
                  )

                  vim.keymap.set(
                    "n", "<leader>br", "<Cmd>BufferLineCloseRight<CR>",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine close all right buffers"})
                  )

                  vim.keymap.set(
                    "n", "<leader>bn", "<Cmd>BufferLineCycleNext<CR>",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine cycle next buffer"})
                  )

                  vim.keymap.set(
                    "n", "<leader>bp", "<Cmd>BufferLineCyclePrev<CR>",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine cycle previous buffer"})
                  )

                  vim.keymap.set(
                    "n", "<leader>bN", "<Cmd>BufferLineMoveNext<CR>",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine move current buffer next"})
                  )

                  vim.keymap.set(
                    "n", "<leader>bP", "<Cmd>BufferLineMovePrev<CR>",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine move current buffer prev"})
                  )

                  vim.keymap.set(
                    "n", "<leader>bk", "<Cmd>BufferLinePick<CR>",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine pick and view buffer"})
                  )

                  vim.keymap.set(
                    "n", "<leader>bc", "<Cmd>BufferLinePickClose<CR>",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine pick and close buffer"})
                  )

                  vim.keymap.set(
                    "n", "<leader>bd", "<Cmd>BufferLineSortByDirectory<CR>",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine sort buffers by directory"})
                  )

                  vim.keymap.set(
                    "n", "<leader>bD", "<Cmd>BufferLineSortByRelativeDirectory<CR>",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine sort buffers by relative directory"})
                  )

                  vim.keymap.set(
                    "n", "<leader>bm", ":BufferLineTabRename ",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine rename the current tab"})
                  )

                  vim.keymap.set(
                    "n", "<leader>bi", "<Cmd>BufferLineTogglePin<CR>",
                    vim.tbl_deep_extend("force", bl_opts,
                      {desc = "BufferLine pin/unpin buffer"})
                  )
                end,
              })
            '';
          }

          {
            plugin = dropbar-nvim;
            type = "lua";
            config = ''
              require("lz.n").load({
                "dropbar.nvim",
                lazy = false,
                after = function()
                  -- Use dropbar as a drop-in replacement to
                  -- Neovim's builtin `vim.ui.select` menu
                  vim.ui.select = require("dropbar.utils.menu").select

                  -- Important dropbar keymaps
                  local dropbar_api = require("dropbar.api")

                  vim.keymap.set(
                    "n", "<leader>pp", dropbar_api.pick,
                    {desc = "Pick symbols in winbar"}
                  )

                  vim.keymap.set(
                    "n", "<leader>ps", dropbar_api.goto_context_start,
                    {desc = "Go to start of current context"}
                  )

                  vim.keymap.set(
                    "n", "<leader>pn", dropbar_api.select_next_context,
                    {desc = "Select next context"}
                  )
                end,
              })
            '';
          }
        ];
      })
    ]);
}
