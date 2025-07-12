{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.treesitterExtraPlugins.enable = let
    inherit (lib) mkEnableOption;
  in
    mkEnableOption "extra tree-sitter plugins for neovim" // {default = true;};

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf optionals;
  in
    mkIf cfg.enable {
      programs.neovim = with pkgs.vimPlugins; {
        extraPackages = [pkgs.tree-sitter];

        plugins =
          [
            {
              type = "lua";
              plugin = nvim-treesitter.withPlugins (tsPlugs:
                nvim-treesitter.allGrammars
                ++ (with tsPlugs; [
                  tree-sitter-norg
                  tree-sitter-norg-meta
                  tree-sitter-org-nvim
                ]));
              config = ''
                require("lz.n").load({
                  "nvim-treesitter",
                  lazy = false,
                  after = function()
                    require("nvim-treesitter.configs").setup({
                      -- A list of parser names, or "all"
                      -- that should always be installed.
                      ensure_installed = {},

                      -- Install parsers synchronously
                      -- (only applied to `ensure_installed`).
                      sync_install = false,

                      -- Automatically install missing parsers when entering buffer.
                      -- Recommendation: set to false if you don't have
                      -- `tree-sitter` CLI installed locally.
                      auto_install = false,

                      -- List of parsers to ignore installing (for "all").
                      ignore_install = {},

                      highlight = {
                        enable = true,

                        -- Disable slow treesitter highlighting for large files.
                        disable = function(lang, buf)
                          local max_filesize = 500 * 1024 -- 500 KB
                          local ok, stats = pcall(
                            vim.loop.fs_stat,
                            vim.api.nvim_buf_get_name(buf)
                          )
                          if ok and stats and stats.size > max_filesize then
                            return true
                          end
                        end,

                        -- Set this to `true` if you depend on "syntax" being enabled
                        -- (like for indentation). Using this option may
                        -- slow down your editor and you may see some
                        -- duplicate highlights. Instead of true it can also
                        -- be a list of languages.
                        additional_vim_regex_highlighting = false,
                      },

                      incremental_selection = {
                        enable = true,
                        keymaps = {
                          -- Set to `false` to disable one of the mappings.
                          init_selection = "<leader>ri",
                          node_incremental = "<leader>rn",
                          scope_incremental = "<leader>rs",
                          node_decremental = "<leader>rN",
                        },
                      },

                      indent = {
                        enable = true
                      },

                      -- Show textobject surrounding definition
                      -- as determined using built-in LSP
                      textobjects = {
                        lsp_interop = {
                          enable = true,
                          border = "none",
                          floating_preview_opts = {},
                          peek_definition_code = {
                            ["<leader>rf"] = {
                              query = "@function.outer",
                              desc = "Show textobject surrounding function definition",
                            },
                            ["<leader>rF"] = {
                              query = "@class.outer",
                              desc = "Show textobject surrounding class definition",
                            },
                          },
                        },
                      },
                    })
                  end,
                })
              '';
            }
          ]
          ++ optionals cfg.treesitterExtraPlugins.enable [
            {
              plugin = nvim-treesitter-context;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "nvim-treesitter-context",
                  event = "BufWinEnter",
                  keys = {
                    {
                      mode = "n", "<leader>rc", function()
                        require("treesitter-context").go_to_context(vim.v.count1)
                      end, silent = true, desc = "Jump to context upwards",
                    },
                  },
                  after = function() require("treesitter-context").setup({}) end,
                })
              '';
            }

            {
              plugin = nvim-treesitter-textobjects;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "nvim-treesitter-textobjects",
                  event = {"BufRead", "BufNewFile"},
                  after = function()
                    require("nvim-treesitter.configs").setup({
                      textobjects = {
                        select = {
                          enable = true,

                          -- Automatically jump forward to textobj, similar to targets.vim
                          lookahead = true,

                          keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["af"] = {
                              query = "@function.outer",
                              desc = "Select outer part of a function region",
                            },
                            ["if"] = {
                              query = "@function.inner",
                              desc = "Select inner part of a function region",
                            },
                            ["ac"] = {
                              query = "@class.outer",
                              desc = "Select outer part of a class region",
                            },
                            -- You can optionally set descriptions to the mappings
                            -- (used in the desc parameter of nvim_buf_set_keymap)
                            -- which plugins like which-key display.
                            ["ic"] = {
                              query = "@class.inner",
                              desc = "Select inner part of a class region",
                            },
                            -- You can also use captures from other
                            -- query groups like `locals.scm`
                            ["as"] = {
                              query = "@scope",
                              query_group = "locals",
                              desc = "Select language scope",
                            },
                          },
                          -- You can choose the select mode (default is charwise "v")
                          --
                          -- Can also be a function which gets passed a table with the
                          -- keys query_string: eg "@function.inner method: eg "v" or "o"
                          -- and should return the mode ("v", "V", or "<c-v>") or
                          -- a table mapping query_strings to modes.
                          selection_modes = {
                            ["@parameter.outer"] = "v", -- charwise
                            ["@function.outer"] = "V", -- linewise
                            ["@class.outer"] = "<c-v>", -- blockwise
                          },
                          -- If you set this to `true` (default is `false`) then any
                          -- textobject is extended to include preceding or succeeding
                          -- whitespace. Succeeding whitespace has priority in order
                          -- to act similarly to eg the built-in `ap`.
                          --
                          -- Can also be a function which gets passed a table with the
                          -- keys query_string: eg "@function.inner" selection_mode:
                          -- eg "v" and should return true of false
                          include_surrounding_whitespace = true,
                        },

                        swap = {
                          enable = true,
                          swap_next = {
                            ["<leader>ra"] = {
                              query = "@parameter.inner",
                              desc = "Next parameter swap",
                            },
                          },
                          swap_previous = {
                            ["<leader>rA"] = {
                              query = "@parameter.inner",
                              desc = "Previous parameter swap",
                            },
                          },
                        },

                        move = {
                          enable = true,
                          set_jumps = true, -- whether to set jumps in the jumplist
                          goto_next_start = {
                            ["<leader>rm"] = {
                              query = "@function.outer",
                              desc = "Next func start"
                            },
                            ["<leader>rk"] = {
                              query = "@class.outer",
                              desc = "Next class start"
                            },
                            --
                            -- You can use regex matching (i.e. lua pattern) and/or pass
                            -- a list in a "query" key to group multiple queries.
                            ["<leader>ro"] = {
                              query = "@loop.*",
                              desc = "Next loop start",
                            },
                            -- ["<leader>ro"] = {query = {"@loop.inner", "@loop.outer"}}
                            --
                            -- You can pass a query group to use query from
                            -- `queries/<lang>/<query_group>.scm file in your runtime
                            -- path. Below example nvim-treesitter's `locals.scm` and
                            -- `folds.scm`. They also provide highlights.scm
                            -- and indent.scm.
                            ["<leader>re"] = {
                              query = "@scope",
                              query_group = "locals",
                              desc = "Next scope",
                            },
                            ["<leader>rz"] = {
                              query = "@fold",
                              query_group = "folds",
                              desc = "Next fold",
                            },
                          },
                          goto_next_end = {
                            ["<leader>rM"] = {
                              query = "@function.outer",
                              desc = "Next function end",
                            },
                            ["<leader>rK"] = {
                              query = "@class.outer",
                              desc = "Next class end",
                            },
                          },
                          goto_previous_start = {
                            ["<leader>rp"] = {
                              query = "@function.outer",
                              desc = "Previous function start",
                            },
                            ["<leader>rq"] = {
                              query = "@class.outer",
                              desc = "Previous class start",
                            },
                          },
                          goto_previous_end = {
                            ["<leader>rP"] = {
                              query = "@function.outer",
                              desc = "Previous function end",
                            },
                            ["<leader>rQ"] = {
                              query = "@class.outer",
                              desc = "Previous class end",
                            },
                          },
                          -- Below will go to either the start or the end, whichever is
                          -- closer. Use if you want more granular movements
                          -- Make it even more gradual by adding multiple queries & regex.
                          goto_next = {
                            ["<leader>rd"] = {
                              query = "@conditional.outer",
                              desc = "Select outer part of next conditional",
                            },
                          },
                          goto_previous = {
                            ["<leader>rD"] = {
                              query = "@conditional.outer",
                              desc = "Select outer part of previous conditional",
                            },
                          }
                        },
                      },
                    })

                    local ts_repeat_move = require(
                      "nvim-treesitter.textobjects.repeatable_move"
                    )

                    -- Repeat movement with ; and ,
                    -- vim way: ; goes to the direction you were moving.
                    vim.keymap.set(
                      {"n", "x", "o"}, ";",
                      ts_repeat_move.repeat_last_move,
                      {desc = "Make movement with ; repeatable"}
                    )

                    vim.keymap.set(
                      {"n", "x", "o"}, ",",
                      ts_repeat_move.repeat_last_move_opposite,
                      {desc = "Make movement with , repeatable"}
                    )

                    -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
                    local to_opts = {expr = true}

                    vim.keymap.set(
                      {"n", "x", "o"}, "f",
                      ts_repeat_move.builtin_f_expr,
                      vim.tbl_deep_extend("force", to_opts,
                        {desc = "Make builtin f repeatable"})
                    )

                    vim.keymap.set(
                      {"n", "x", "o"}, "F",
                      ts_repeat_move.builtin_F_expr,
                      vim.tbl_deep_extend("force", to_opts,
                        {desc = "Make builtin F repeatable"})
                    )

                    vim.keymap.set(
                      {"n", "x", "o"}, "t",
                      ts_repeat_move.builtin_t_expr,
                      vim.tbl_deep_extend("force", to_opts,
                        {desc = "Make builtin t repeatable"})
                    )

                    vim.keymap.set(
                      {"n", "x", "o"}, "T",
                      ts_repeat_move.builtin_T_expr,
                      vim.tbl_deep_extend("force", to_opts,
                        {desc = "Make builtin T repeatable"})
                    )
                  end,
                })
              '';
            }

            {
              plugin = nvim-treesitter-textsubjects;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "nvim-treesitter-textsubjects",
                  event = {"BufRead", "BufNewFile"},
                })
              '';
            }

            {
              plugin = nvim-autopairs;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "nvim-autopairs",
                  event = "InsertEnter",
                  after = function()
                    require("nvim-autopairs").setup({
                      check_ts = true,
                      enable_check_bracket_line = false,
                      ignored_next_char = "[%w%d]",
                      fast_wrap = {},
                    })
                  end,
                })
              '';
            }

            {
              plugin = nvim-ts-autotag;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "nvim-ts-autotag",
                  event = {"BufRead", "BufNewFile"},
                  after = function() require("nvim-ts-autotag").setup() end,
                })
              '';
            }
          ];
      };
    };
}
