{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.telescopeExtraPlugins.enable = let
    inherit (lib) mkEnableOption;
  in
    mkEnableOption "extra telescope plugins for neovim" // {default = true;};

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf optionals optionalString;
  in
    mkIf cfg.enable (with pkgs.vimPlugins; {
      programs.neovim = {
        extraPackages = with pkgs; [
          fd
          ripgrep
        ];

        plugins =
          [
            plenary-nvim
            nvim-web-devicons
            telescope-fzf-native-nvim
            {
              plugin = telescope-nvim;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "telescope.nvim",
                  cmd = "Telescope",

                  keys = {
                    -- Define some sane mappings
                    {
                      mode = "n", "<leader>tf",
                      require("telescope.builtin").find_files,
                      desc = "Telescope find files",
                    },

                    {
                      mode = "n", "<leader>tg",
                      require("telescope.builtin").grep_string,
                      desc = "Telescope grep sting under the cursor or selection",
                    },

                    {
                      mode = "n", "<leader>tl",
                      require("telescope.builtin").live_grep,
                      desc = "Telescope live search for a string using ripgrep",
                    },

                    {
                      mode = "n", "<leader>tb",
                      require("telescope.builtin").buffers,
                      desc = "Telescope list currently open buffers",
                    },

                    {
                      mode = "n", "<leader>to",
                      require("telescope.builtin").oldfiles,
                      desc = "Telescope list previously open files",
                    },

                    {
                      mode = "n", "<leader>tc",
                      require("telescope.builtin").commands,
                      desc = "Telescope list available plugin or user commands",
                    },

                    {
                      mode = "n", "<leader>tC",
                      require("telescope.builtin").command_history,
                      desc = "Telescope list previously executed commands",
                    },

                    {
                      mode = "n", "<leader>tS",
                      require("telescope.builtin").search_history,
                      desc = "Telescope list previous searches",
                    },

                    {
                      mode = "n", "<leader>th",
                      require("telescope.builtin").help_tags,
                      desc = "Telescope list all available help tags",
                    },

                    {
                      mode = "n", "<leader>tm",
                      require("telescope.builtin").man_pages,
                      desc = "Telescope list all available manpage entries",
                    },

                    {
                      mode = "n", "<leader>tq",
                      require("telescope.builtin").quickfix,
                      desc = "Telescope list items in the quickfix list",
                    },

                    {
                      mode = "n", "<leader>tQ",
                      require("telescope.builtin").quickfixhistory,
                      desc = "Telescope list all quickfix lists in the history",
                    },

                    {
                      mode = "n", "<leader>tj",
                      require("telescope.builtin").jumplist,
                      desc = "Telescope list Jump List entries",
                    },

                    {
                      mode = "n", "<leader>tv",
                      require("telescope.builtin").vim_options,
                      desc = "Telescope list vim options",
                    },

                    {
                      mode = "n", "<leader>tr",
                      require("telescope.builtin").registers,
                      desc = "Telescope list vim registers",
                    },

                    {
                      mode = "n", "<leader>ta",
                      require("telescope.builtin").autocommands,
                      desc = "Telescope list vim autocommands"
                    },

                    {
                      mode = "n", "<leader>tp",
                      require("telescope.builtin").spell_suggest,
                      desc = "Telescope suggest spelling for the word under the cursor",
                    },

                    {
                      mode = "n", "<leader>tk",
                      require("telescope.builtin").keymaps,
                      desc = "Telescope list normal mode keymaps",
                    },

                    {
                      mode = "n", "<leader>tF",
                      require("telescope.builtin").filetypes,
                      desc = "Telescope list all available filetypes",
                    },

                    {
                      mode = "n", "<leader>tH",
                      require("telescope.builtin").highlights,
                      desc = "Telescope list all available highlights",
                    },

                    {
                      mode = "n", "<leader>tz",
                      require("telescope.builtin").current_buffer_fuzzy_find,
                      desc = "Telescope live fuzzy search inside of the current buffer",
                    },

                    {
                      mode = "n", "<leader>tt",
                      require("telescope.builtin").treesitter,
                      desc = "Telescope list all symbols from Treesitter",
                    },

                    {
                      mode = "n", "<leader>cc", function()
                        require("telescope").extensions.neoclip.default({"default"})
                      end,
                      desc = "Telescope clipboard history",
                    },

                    {
                      mode = "n", "<leader>cm", function()
                        require("telescope").extensions.macroscope.default({"default"})
                      end,
                      desc = "Telescope macro history",
                    },
                ${
                  optionalString cfg.telescopeExtraPlugins.enable ''
                    {
                      mode = "n", "<leader>tu",
                      require("telescope").extensions.undo.undo,
                      desc = "Undo history using telescope",
                    },

                    {
                      mode = "n", "<leader>ty", function()
                        require("telescope").extensions.jsonfly.jsonfly({})
                      end,
                      ft = {"json", "xml", "yaml"},
                      desc = "Search for keys in JSON, XML & YAML files using jsonfly",
                    },
                  ''
                }
                ${
                  optionalString cfg.tabline.enable ''
                    {
                      mode = "n", "<leader>ts",
                      require("telescope").extensions.scope.buffers,
                      desc = "Show all buffers from all scoped tabs",
                    },
                  ''
                }
                ${
                  optionalString cfg.ui.enable ''
                    {
                      mode = "n", "<leader>tn",
                      require("telescope").extensions.notify.notify,
                      desc = "Show notification history",
                    },
                  ''
                }
                  },

                  after = function()
                    require("telescope").load_extension("fzf")
                ${
                  optionalString cfg.telescopeExtraPlugins.enable ''
                    require("telescope").load_extension("jsonfly")
                    require("telescope").load_extension("undo")
                  ''
                }
                ${
                  optionalString cfg.tabline.enable ''
                    require("telescope").load_extension("scope")
                  ''
                }
                ${
                  optionalString cfg.ui.enable ''
                    -- Use the `notify` Telescope extension to search history
                    require("telescope").load_extension("notify")
                  ''
                }
                  end,
                })
              '';
            }
          ]
          ++ optionals cfg.telescopeExtraPlugins.enable [
            {
              plugin = jsonfly-nvim;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "jsonfly.nvim",
                  lazy = false,
                })
              '';
            }

            {
              plugin = telescope-undo-nvim;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "telescope-undo.nvim",
                  lazy = false,
                })
              '';
            }

            sqlite-lua
            {
              plugin = nvim-neoclip-lua;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "nvim-neoclip.lua",
                  lazy = false,
                  after = function()
                    require("neoclip").setup({
                      enable_persistent_history = true,
                      default_register = { '"', "*", "+", "a", "b" },
                      default_register_macros = { "q", "a", "b" },
                    })

                    vim.keymap.set(
                      "n", "<leader>ct", require("neoclip").toggle,
                      {desc = "Toggle Neoclip history recording"}
                    )

                    vim.keymap.set(
                      "n", "<leader>cr", require("neoclip").clear_history,
                      {desc = "Clear the entire neoclip history"}
                    )

                    vim.keymap.set(
                      "n", "<leader>cl", require("neoclip").db_pull,
                      {desc = "Neoclip pull the database into session history"}
                    )

                    vim.keymap.set(
                      "n", "<leader>ch", require("neoclip").db_push,
                      {desc = "Neoclip push session history into the database"}
                    )
                  end,
                })
              '';
            }
          ];
      };
    });
}
