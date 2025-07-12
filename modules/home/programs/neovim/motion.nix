{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.motion.enable = let
    inherit (lib) mkEnableOption;
  in
    mkEnableOption "motion-related plugins" // {default = true;};

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.motion.enable) {
      programs.neovim.plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-surround;
          optional = true;
          type = "lua";
          config = ''
            require("lz.n").load({
              "nvim-surround",
              event = "DeferredUIEnter",
              after = function() require("nvim-surround").setup() end,
            })
          '';
        }

        mini-icons
        nvim-web-devicons
        {
          plugin = which-key-nvim;
          optional = true;
          type = "lua";
          config = ''
            require("lz.n").load({
              "which-key.nvim",
              event = "DeferredUIEnter",
              keys = {
                {
                  mode = "n", "<leader>?", function()
                    require("which-key").show({global = false})
                  end, desc = "which-key buffer local keymaps",
                }
              },
              after = function()
                vim.o.timeout = true
                vim.o.timeoutlen = 500
                require("which-key").setup({})
              end,
            })
          '';
        }

        plenary-nvim
        {
          plugin = harpoon2;
          optional = true;
          type = "lua";
          config = ''
            require("lz.n").load({
              "harpoon2",
              keys = {
                {
                  mode = "n", "<leader>ha", function()
                    require("harpoon"):list():add()
                  end, desc = "Add buffers to Harpoon list",
                },

                {
                  mode = "n", "<leader>hr", function()
                    require("harpoon"):list():select(1)
                  end, desc = "Select buffer 1 from Harpoon list",
                },

                {
                  mode = "n", "<leader>hs", function()
                    require("harpoon"):list():select(2)
                  end, desc = "Select buffer 2 from Harpoon list",
                },

                {
                  mode = "n", "<leader>hx", function()
                    require("harpoon"):list():select(3)
                  end, desc = "Select buffer 3 from Harpoon list",
                },

                {
                  mode = "n", "<leader>hc", function()
                    require("harpoon"):list():select(4)
                  end, desc = "Select buffer 4 from Harpoon list",
                },

                {
                  mode = "n", "<leader>hd", function()
                    require("harpoon"):list():select(5)
                  end, desc = "Select buffer 5 from Harpoon list",
                },

                -- Toggle previous & next buffers stored within Harpoon list
                {
                  mode = "n", "<leader>hp", function()
                    require("harpoon"):list():prev()
                  end, desc = "Toggle previous buffer in Harpoon list",
                },

                {
                  mode = "n", "<leader>hn", function()
                    require("harpoon"):list():next()
                  end, desc = "Toggle next buffer in Harpoon list",
                },

                -- Basic telescope configuration
                {
                  mode = "n", "<leader>ht", function()
                    local conf = require("telescope.config").values

                    local file_paths = {}
                    for _, item in ipairs(require("harpoon"):list().items) do
                      table.insert(file_paths, item.value)
                    end

                    require("telescope.pickers").new({}, {
                      prompt_title = "Harpoon",
                      finder = require("telescope.finders").new_table({
                        results = file_paths,
                      }),
                      previewer = conf.file_previewer({}),
                      sorter = conf.generic_sorter({}),
                    }):find()
                  end, desc = "Open Harpoon quick menu in Telescope",
                },
              },
              after = function() require("harpoon"):setup({}) end,
            })
          '';
        }

        vim-repeat
        {
          plugin = leap-nvim;
          type = "lua";
          config = ''
            require("lz.n").load({
              "leap.nvim",
              lazy = false,
              after = function()
                vim.keymap.set(
                  {"n", "x", "o"}, "<leader>s", "<Plug>(leap)",
                  {desc = "Leap"}
                )

                vim.keymap.set(
                  {"n", "x", "o"}, "<leader>S", "<Plug>(leap-from-window)",
                  {desc = "Leap from window"}
                )

                -- Remote operations, with default visual selection
                vim.keymap.set({"n", "x", "o"}, "<leader>e", function ()
                  require("leap.remote").action({input = "v"})
                end, {desc = "Perform remote operations with Leap"})

                -- Exclude whitespace and the middle of alphabetic words from preview:
                --   foobar[baaz] = quux
                --   ^----^^^--^^-^-^--^
                require("leap").opts.preview_filter =
                  function (ch0, ch1, ch2)
                    return not (
                      ch1:match("%s") or
                      ch0:match("%a") and ch1:match("%a") and ch2:match("%a")
                    )
                end

                -- Equivalence classes for brackets and quotes
                require("leap").opts.equivalence_classes = {
                  " \t\r\n", "([{",
                  ")]}", "'\"`",
                }

                -- Use the traversal keys to repeat the previous motion
                -- without explicitly invoking Leap
                require("leap.user").set_repeat_keys("<enter>", "<backspace>")
              end,
            })
          '';
        }
      ];
    };
}
