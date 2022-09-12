# A user overlay for Neovim with necessary plugins.
self: super: {
  neovim = super.neovim.override {
    configure = {
      packages.nix = {
        # Loaded on launch.
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
                tree-sitter-fennel
                tree-sitter-fish
                tree-sitter-go
                tree-sitter-hjson
                tree-sitter-html
                tree-sitter-http
                tree-sitter-javascript
                tree-sitter-jsdoc
                tree-sitter-json
                tree-sitter-json5
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
        # Manually loadable by calling `:packadd $plugin-name`
        # To automatically load a plugin when opening a filetype, add init lines.
        opt = with super.pkgs.vimPlugins; [
          glow-nvim
          editorconfig-nvim
          neorg
        ];
      };
    };
  };
}
