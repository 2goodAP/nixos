# A user overlay for Neovim with necessary plugins.
self: super: {
  neovim = super.neovim.override {
    configure = {
      customRC = ''
        lua << EOF

        -- ============================ --
        -- NeoVim Lua Config (init.lua) --
        -- ============================ --

        -- Enable true colors.
        vim.opt.termguicolors = true

        -- Show line numbers.
        vim.opt.number = true
        vim.opt.relativenumber = true

        -- Enable live substitution.
        vim.opt.inccommand = "split"

        -- Enable softwrap.
        vim.opt.wrap = true
        vim.opt.linebreak = true
        vim.opt.list = false
        vim.opt.showbreak = "> "

        -- Enable case-insensitive search (except for explicitly uppercase chars).
        vim.opt.smartcase = true
        vim.opt.ignorecase = true

        -- Handle tab width and expansion.
        vim.opt.tabstop=4
        vim.opt.shiftwidth=0
        vim.opt.expandtab = true

        -- Highlight the current cursor line.
        vim.opt.cursorline = true

        -- Display column break at 80 characters.
        vim.opt.colorcolumn = "80"

        -- Split manipulation.
        vim.opt.splitright = true
        vim.opt.splitbelow = true

        -- Remap the leader to ",".
        vim.g.mapleader = ","

        -- ----------------------------------------- --
        -- Vim tab and split navigation keybindings. --
        -- ----------------------------------------- --

        -- Terminal mode
        -- -------------
        -- 'Escaping' to normal mode in terminal mode
        vim.keymap.set(
          "t", "<A-[>", [[<C-\><C-n>]],
          {desc = "Escape to normal mode from Terminal mode."}
        )
        -- Split navigation
        vim.keymap.set(
          "t", "<C-h>", [[<C-\><C-n><C-w>h]],
          {desc = "Navigate to left split in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<C-l>", [[<C-\><C-n><C-w>l]],
          {desc = "Navigate to right split in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<C-j>", [[<C-\><C-n><C-w>j]],
          {desc = "Navigate to down split in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<C-k>", [[<C-\><C-n><C-w>k]],
          {desc = "Navigate to up split in Terminal mode."}
        )
        -- Tab navigation
        vim.keymap.set(
          "t", "<A-l>", [[<C-\><C-n>gt]],
          {desc = "Navigate to right tab in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<A-h>", [[<C-\><C-n>gT]],
          {desc = "Navigate to left tab in Terminal mode."}
        )
        -- Tab jumping
        vim.keymap.set(
          "t", "<A-1>", [[<C-\><C-n>1gt]],
          {desc = "Jump to tab #1 in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<A-2>", [[<C-\><C-n>2gt]],
          {desc = "Jump to tab #2 in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<A-3>", [[<C-\><C-n>3gt]],
          {desc = "Jump to tab #3 in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<A-4>", [[<C-\><C-n>4gt]],
          {desc = "Jump to tab #4 in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<A-5>", [[<C-\><C-n>5gt]],
          {desc = "Jump to tab #5 in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<A-6>", [[<C-\><C-n>6gt]],
          {desc = "Jump to tab #6 in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<A-7>", [[<C-\><C-n>7gt]],
          {desc = "Jump to tab #7 in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<A-8>", [[<C-\><C-n>8gt]],
          {desc = "Jump to tab #8 in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<A-9>", [[<C-\><C-n>9gt]],
          {desc = "Jump to tab #9 in Terminal mode."}
        )
        vim.keymap.set(
          "t", "<A-0>", [[<C-\><C-n>0gt]],
          {desc = "Jump to tab #10 in Terminal mode."}
        )

        -- Normal mode
        -- -----------
        vim.keymap.set(
          "n", "<C-k>", "<C-w>k",
          {desc = "Navigate to left split in Normal mode."}
        )
        vim.keymap.set(
          "n", "<C-j>", "<C-w>j",
          {desc = "Navigate to right split in Normal mode."}
        )
        vim.keymap.set(
          "n", "<C-h>", "<C-w>h",
          {desc = "Navigate to down split in Normal mode."}
        )
        vim.keymap.set(
          "n", "<C-l>", "<C-w>l",
          {desc = "Navigate to up split in Normal mode."}
        )
        -- Tab navigation
        vim.keymap.set(
          "n", "<A-l>", "gt",
          {desc = "Navigate to right tab in Normal mode."}
        )
        vim.keymap.set(
          "n", "<A-h>", "gT",
          {desc = "Navigate to left tab in Normal mode."}
        )
        -- Tab jumping
        vim.keymap.set(
          "n", "<A-1>", "1gt",
          {desc = "Jump to tab #1 in Normal mode."}
        )
        vim.keymap.set(
          "n", "<A-2>", "2gt",
          {desc = "Jump to tab #2 in Normal mode."}
        )
        vim.keymap.set(
          "n", "<A-3>", "3gt",
          {desc = "Jump to tab #3 in Normal mode."}
        )
        vim.keymap.set(
          "n", "<A-4>", "4gt",
          {desc = "Jump to tab #4 in Normal mode."}
        )
        vim.keymap.set(
          "n", "<A-5>", "5gt",
          {desc = "Jump to tab #5 in Normal mode."}
        )
        vim.keymap.set(
          "n", "<A-6>", "6gt",
          {desc = "Jump to tab #6 in Normal mode."}
        )
        vim.keymap.set(
          "n", "<A-7>", "7gt",
          {desc = "Jump to tab #7 in Normal mode."}
        )
        vim.keymap.set(
          "n", "<A-8>", "8gt",
          {desc = "Jump to tab #8 in Normal mode."}
        )
        vim.keymap.set(
          "n", "<A-9>", "9gt",
          {desc = "Jump to tab #9 in Normal mode."}
        )
        vim.keymap.set(
          "n", "<A-0>", "0gt",
          {desc = "Jump to tab #10 in Normal mode."}
        )

        -- Command/Insert/Operator/Visual modes
        -- ------------------------------------
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<C-k>", "<ESC><C-w>k",
          {desc = "Navigate to left split in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<C-j>", "<ESC><C-w>j",
          {desc = "Navigate to right split in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<C-h>", "<ESC><C-w>h",
          {desc = "Navigate to down split in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<C-l>", "<ESC><C-w>l",
          {desc = "Navigate to up split in Command/Insert/Operator/Visual modes."}
        )
        -- Tab navigation
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<A-l>", "<ESC>gt",
          {desc = "Navigate to right tab in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<A-h>", "<ESC>gT",
          {desc = "Navigate to left tab in Command/Insert/Operator/Visual modes."}
        )
        -- Tab jumping
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<A-1>", "<ESC>1gt",
          {desc = "Jump to tab #1 in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<A-2>", "<ESC>2gt",
          {desc = "Jump to tab #2 in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<A-3>", "<ESC>3gt",
          {desc = "Jump to tab #3 in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<A-4>", "<ESC>4gt",
          {desc = "Jump to tab #4 in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<A-5>", "<ESC>5gt",
          {desc = "Jump to tab #5 in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<A-6>", "<ESC>6gt",
          {desc = "Jump to tab #6 in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<A-7>", "<ESC>7gt",
          {desc = "Jump to tab #7 in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<A-8>", "<ESC>8gt",
          {desc = "Jump to tab #8 in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<A-9>", "<ESC>9gt",
          {desc = "Jump to tab #9 in Command/Insert/Operator/Visual modes."}
        )
        vim.keymap.set(
          {"c", "i", "o", "v"}, "<A-0>", "<ESC>0gt",
          {desc = "Jump to tab #10 in Command/Insert/Operator/Visual modes."}
        )

        -- Hide netrw directory listing banner.
        vim.g.netrw_banner = false

        -- Set background to dark if running in a Linux Console.
        if vim.env.TERM == "linux" then
          vim.cmd("colorscheme tokyonight-storm")
        else
          vim.cmd("colorscheme tokyonight-day")
        end

        EOF
      '';

      packages.nix = {
        start = with super.pkgs.vimPlugins; [
          # Deps
          plenary-nvim
          # LSP
          nvim-lspconfig
          lsp_signature-nvim
          null-ls-nvim
          # DAP
          nvim-dap
          nvim-dap-ui
          # Treesitter
          nvim-autopairs
          (nvim-treesitter.withPlugins (
            plugins:
              with plugins; [
                tree-sitter-bash
                tree-sitter-c
                tree-sitter-cmake
                tree-sitter-comment
                tree-sitter-cpp
                tree-sitter-css
                tree-sitter-cuda
                tree-sitter-dart
                tree-sitter-dockerfile
                tree-sitter-embedded-template
                tree-sitter-fish
                tree-sitter-go
                tree-sitter-haskell
                tree-sitter-hjson
                tree-sitter-html
                tree-sitter-http
                tree-sitter-javascript
                tree-sitter-jsdoc
                tree-sitter-json
                tree-sitter-json5
                tree-sitter-julia
                tree-sitter-kotlin
                tree-sitter-latex
                tree-sitter-lua
                tree-sitter-make
                tree-sitter-markdown
                tree-sitter-markdown-inline
                tree-sitter-nix
                tree-sitter-norg
                tree-sitter-org-nvim
                tree-sitter-perl
                tree-sitter-python
                tree-sitter-r
                tree-sitter-regex
                tree-sitter-rst
                tree-sitter-ruby
                tree-sitter-rust
                tree-sitter-scala
                tree-sitter-scss
                tree-sitter-sql
                tree-sitter-toml
                tree-sitter-tsx
                tree-sitter-typescript
                tree-sitter-vim
                tree-sitter-vue
                tree-sitter-yaml
              ]
          ))
          nvim-treesitter-context
          nvim-treesitter-textobjects
          nvim-ts-autotag
          # Completion
          nvim-cmp
          cmp-buffer
          cmp-calc
          cmp-cmdline
          cmp-dictionary
          cmp-git
          cmp_luasnip
          cmp-nvim-lsp
          cmp-nvim-lsp-signature-help
          cmp-nvim-lsp-document-symbol
          cmp-nvim-lua
          cmp-path
          cmp-treesitter
          # Motion
          comment-nvim
          nvim-surround
          which-key-nvim
          hop-nvim
          # Snippets
          luasnip
          # Fuzzy search
          telescope-nvim
          # Git
          neogit
          gitsigns-nvim
          # Colorscheme
          tokyonight-nvim
          # Statusline
          lualine-nvim
          bufferline-nvim
          # UI
          bufdelete-nvim
          indent-blankline-nvim
          nvim-bqf
          nvim-tree-lua
          registers-nvim
          trouble-nvim
        ];

        opt = with super.pkgs.vimPlugins; [
          # Markdown
          glow-nvim
          # Editorconfig
          editorconfig-nvim
          # Org-mode
          neorg
        ];
      };
    };
  };
}
