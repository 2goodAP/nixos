{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    ui.enable = mkEnableOption "fancy ui for neovim" // {default = true;};

    colorscheme = mkOption {
      type = types.enum ["rose-pine"];
      default = "rose-pine";
      description = ''
        The colorscheme to use for neovim. Must be one of ['rose-pine'].";
      '';
    };
  };

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf mkMerge optionalString;
  in
    mkIf cfg.enable (mkMerge [
      (mkIf (cfg.colorscheme == "rose-pine") {
        programs.neovim.plugins = with pkgs.vimPlugins; [
          {
            plugin = rose-pine;
            type = "lua";
            config = ''
              require("rose-pine").setup({
                dark_variant = "moon",
                dim_inactive_windows = true,
                highlight_groups = {
              ${optionalString cfg.tabline.enable ''
                BufferLineTabSelected = {fg = "text", bg = "base"},
                BufferLineIndicatorSelected = {fg = "subtle", bg = "base"},
              ''}
              ${optionalString cfg.git.enable ''
                DiffviewFilePanelFileName = {fg = "text"},
              ''}
                  SnacksIndentChunk = {fg = "iris"},
                  SnacksIndentScope = {fg = "iris"},
                },
              })
              vim.cmd.colorscheme("rose-pine")
            '';
          }
        ];
      })

      (mkIf cfg.ui.enable {
        programs.neovim.plugins = with pkgs.vimPlugins; [
          nui-nvim
          nvim-web-devicons
          plenary-nvim
          {
            plugin = neo-tree-nvim;
            type = "lua";
            config = ''
              require("lz.n").load({
                "neo-tree.nvim",
                lazy = false,
                after = function()
                  local function nt_on_move(data)
                    Snacks.rename.on_rename_file(data.source, data.destination)
                  end

                  require("neo-tree").setup({
                    sources = {
                      "filesystem",
                      "buffers",
                      "git_status",
                      "document_symbols",
                    },
                    auto_clean_after_session_restore = true,
                    close_if_last_window = true,
                    popup_border_style = "rounded",
                    source_selector = {statusline = true},
                    event_handlers = {
                      {event = "file_moved", handler = nt_on_move},
                      {event = "file_renamed", handler = nt_on_move},
                    },
                    window = {
                      mappings = {
                        ["P"] = {"toggle_preview", config = {use_snacks_image = true}},
                        ["s"] = "split_with_window_picker",
                        ["S"] = "vsplit_with_window_picker",
                        ["z"] = "close_all_subnodes",
                        ["Z"] = "close_all_nodes",
                      },
                    },
                    filesystem = {
                      filtered_items = {
                        alwyas_show_by_pattern = {".env*", ".*ignore"},
                      },
                    },
                  })

                  -- Neotree keymaps
                  vim.keymap.set(
                    "n", "<leader>of",
                    "<Cmd>Neotree left filesystem toggle reveal<CR>",
                    {desc = "Neotree toggle filesystem to the left"}
                  )

                  vim.keymap.set(
                    "n", "<leader>ob",
                    "<Cmd>Neotree left buffers toggle reveal<CR>",
                    {desc = "Neotree toggle buffers to the left"}
                  )

                  vim.keymap.set(
                    "n", "<leader>og",
                    "<Cmd>Neotree left git_status toggle<CR>",
                    {desc = "Neotree show git status as a float"}
                  )

                  vim.keymap.set(
                    "n", "<leader>od",
                    "<Cmd>Neotree right selector=false document_symbols toggle<CR>",
                    {desc = "Neotree toggle document symbols to the right"}
                  )

                  vim.keymap.set(
                    "n", "<leader>ot",
                    ":Neotree float selector=false git_status git_base=", {
                      desc = "Neotree show git status for given ref, commit or tag",
                    }
                  )

                  vim.keymap.set(
                    "n", "<leader>op",
                    "<Cmd>Neotree float selector=false filesystem"
                      .. " reveal_file=<cfile> reveal_force_cwd<CR>",
                    {desc = "Neotree show filesystem for a file under the cursor"}
                  )
                end,
              })
            '';
          }

          {
            plugin = nvim-notify;
            type = "lua";
            config = ''
              require("lz.n").load({
                "nvim-notify",
                lazy = false,
                after = function()
                  vim.notify = require("notify")
                end,
              })
            '';
          }
        ];
      })
    ]);
}
