{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.treesitter = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "core tree-sitter features for neovim";
    extraPlugins.enable = mkEnableOption "Whether oor not to enable extra tree-sitter features for neovim.";
  };

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf optionals;
  in
    mkIf cfg.treesitter.enable {
      programs.neovim = {
        extraPackages = [pkgs.tree-sitter];

        plugins =
          [
            {
              type = "lua";
              plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (
                plugs:
                  with plugs; [
                    awk
                    bash
                    c
                    cmake
                    comment
                    commonlisp
                    cpp
                    css
                    csv
                    cuda
                    dart
                    diff
                    dockerfile
                    dot
                    embedded-template
                    fennel
                    fish
                    git_rebase
                    gitattributes
                    gitcommit
                    gitignore
                    go
                    haskell
                    hjson
                    html
                    http
                    ini
                    javascript
                    jsdoc
                    json
                    json5
                    julia
                    jq
                    kotlin
                    latex
                    lua
                    luadoc
                    luap
                    make
                    markdown
                    markdown-inline
                    matlab
                    meson
                    nasm
                    ninja
                    nix
                    norg
                    nu
                    objdump
                    passwd
                    perl
                    printf
                    pymanifest
                    python
                    query
                    r
                    rasi
                    regex
                    requirements
                    robots
                    rst
                    ruby
                    rust
                    scala
                    scss
                    snakemake
                    sparql
                    sql
                    ssh_config
                    strace
                    tmux
                    todotxt
                    toml
                    tsv
                    tsx
                    typescript
                    udev
                    vim
                    vimdoc
                    vue
                    xml
                    yaml
                    yuck

                    tree-sitter-norg-meta
                    tree-sitter-org-nvim
                  ]
              );
              config = ''
                require("nvim-treesitter.configs").setup({
                  -- A list of parser names, or "all" that should always be installed.
                  ensure_installed = {},

                  -- Install parsers synchronously (only applied to `ensure_installed`).
                  sync_install = false,

                  -- Automatically install missing parsers when entering buffer.
                  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally.
                  auto_install = false,

                  -- List of parsers to ignore installing (for "all").
                  ignore_install = {},

                  highlight = {
                    enable = true,

                    -- Disable slow treesitter highlighting for large files.
                    disable = function(lang, buf)
                      local max_filesize = 500 * 1024 -- 500 KB
                      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                      if ok and stats and stats.size > max_filesize then
                        return true
                      end
                    end,

                    -- Set this to `true` if you depend on "syntax" being enabled
                    -- (like for indentation). Using this option may slow down your editor,
                    -- and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages.
                    additional_vim_regex_highlighting = false,
                  },

                  incremental_selection = {
                    enable = true,
                    keymaps = {
                      -- Set to `false` to disable one of the mappings.
                      init_selection = "gnn",
                      node_incremental = "grn",
                      scope_incremental = "grc",
                      node_decremental = "grm",
                    },
                  },

                  indent = {
                    enable = true
                  },
                })

                -- Folding
                vim.opt.foldmethod = "expr"
                vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
                vim.opt.foldenable = false  -- Disable folding at startup.
              '';
            }
          ]
          ++ optionals cfg.treesitter.extraPlugins.enable (with pkgs.vimPlugins; [
            {
              plugin = nvim-autopairs;
              type = "lua";
              config = ''
                require("nvim-autopairs").setup({
                  check_ts = true,
                  enable_check_bracket_line = false,
                  ignored_next_char = "[%w%d]",
                  fast_wrap = {},
                })
              '';
            }
            {
              plugin = nvim-treesitter-context;
              type = "lua";
              config = ''
                local ts_context = require("treesitter-context")
                ts_context.setup({})
                -- Jump to context (upwards).
                vim.keymap.set("n", "[c", function()
                    ts_context.go_to_context()
                  end, {silent = true, desc = "Jump to context (upwards)."}
                )
                -- Jump to context (downwards).
                vim.keymap.set("n", "]c", function()
                    ts_context.go_to_context()
                  end, {silent = true, desc = "Jump to context (downwards)."}
                )
              '';
            }
            {
              plugin = nvim-treesitter-textobjects;
              type = "lua";
              config = ''
                require("nvim-treesitter.configs").setup({
                  textobjects = {
                    select = {
                      enable = true,

                      -- Automatically jump forward to textobj, similar to targets.vim
                      lookahead = true,

                      keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        -- You can optionally set descriptions to the mappings
                        -- (used in the desc parameter of nvim_buf_set_keymap)
                        -- which plugins like which-key display.
                        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                        -- You can also use captures from other query groups like `locals.scm`
                        ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                      },
                      -- You can choose the select mode (default is charwise "v")
                      --
                      -- Can also be a function which gets passed a table with the keys
                      -- * query_string: eg "@function.inner"
                      -- * method: eg "v" or "o"
                      -- and should return the mode ("v", "V", or "<c-v>") or a table
                      -- mapping query_strings to modes.
                      selection_modes = {
                        ["@parameter.outer"] = "v", -- charwise
                        ["@function.outer"] = "V", -- linewise
                        ["@class.outer"] = "<c-v>", -- blockwise
                      },
                      -- If you set this to `true` (default is `false`) then any textobject is
                      -- extended to include preceding or succeeding whitespace. Succeeding
                      -- whitespace has priority in order to act similarly to eg the built-in
                      -- `ap`.
                      --
                      -- Can also be a function which gets passed a table with the keys
                      -- * query_string: eg "@function.inner"
                      -- * selection_mode: eg "v"
                      -- and should return true of false
                      include_surrounding_whitespace = true,
                    },

                    swap = {
                      enable = true,
                      swap_next = {
                        ["<leader>a"] = "@parameter.inner",
                      },
                      swap_previous = {
                        ["<leader>A"] = "@parameter.inner",
                      },
                    },

                    move = {
                      enable = true,
                      set_jumps = true, -- whether to set jumps in the jumplist
                      goto_next_start = {
                        ["]m"] = "@function.outer",
                        ["]]"] = { query = "@class.outer", desc = "Next class start" },
                        --
                        -- You can use regex matching (i.e. lua pattern) and/or pass
                        -- a list in a "query" key to group multiple queries.
                        ["]o"] = "@loop.*",
                        -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
                        --
                        -- You can pass a query group to use query from
                        -- `queries/<lang>/<query_group>.scm file in your runtime path.
                        -- Below example nvim-treesitter's `locals.scm` and `folds.scm`.
                        -- They also provide highlights.scm and indent.scm.
                        ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
                      },
                      goto_next_end = {
                        ["]M"] = "@function.outer",
                        ["]["] = "@class.outer",
                      },
                      goto_previous_start = {
                        ["[m"] = "@function.outer",
                        ["[["] = "@class.outer",
                      },
                      goto_previous_end = {
                        ["[M"] = "@function.outer",
                        ["[]"] = "@class.outer",
                      },
                      -- Below will go to either the start or the end, whichever is closer.
                      -- Use if you want more granular movements
                      -- Make it even more gradual by adding multiple queries and regex.
                      goto_next = {
                        ["]d"] = "@conditional.outer",
                      },
                      goto_previous = {
                        ["[d"] = "@conditional.outer",
                      }
                    },
                  },
                })

                local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
                -- Repeat movement with ; and ,
                -- vim way: ; goes to the direction you were moving.
                vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
                vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

                -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
                vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
                vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
                vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
                vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
              '';
            }
            {
              plugin = nvim-ts-autotag;
              type = "lua";
              config = "require('nvim-ts-autotag').setup({})";
            }
          ]);
      };
    };
}
