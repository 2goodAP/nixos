{
  config,
  lib,
  pkgs,
  ...
}: {
  options.machine.programs.neovim.lsp = let
    inherit (lib) mkIf mkEnableOption optionals;
  in {
    enable = mkEnableOption "Whether or not to enable lsp-related plugins.";

    lspsaga.enable = mkEnableOption "Whether or not to enable lspsaga.nvim.";

    lspSignature.enable =
      mkEnableOption "Whether or not to enable lsp-signature.nvim.";
  };

  config = let
    cfg = config.machine.programs.neovim;
    inherit (lib) mkIf optionals;
  in
    mkIf cfg.lsp.enable {
      machine.programs.neovim.startPackages =
        [
          pkgs.vimPlugins.nvim-lspconfig
          pkgs.vimPlugins.null-ls
        ]
        ++ (
          optionals cfg.lsp.lspsaga.enable [pkgs.vimPlugins.lspsaga-nvim]
        )
        ++ (
          optionals cfg.lsp.lspSignature.enable [pkgs.vimPlugins.lsp_signature-nvim]
        );

      machine.programs.neovim.luaConfig = let
        writeIfElse = cond: trueMsg: falseMsg:
          if cond
          then trueMsg
          else falseMsg;
      in ''
          -- Mappings.
          -- See `:help vim.diagnostic.*` for documentation on
          -- any of the below functions.
          local opts = {noremap=true, silent=true}
          vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
          vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

          -- Use an on_attach function to only map the following keys
          -- after the language server attaches to the current buffer.
          local on_attach = function(client, bufnr)
            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

            -- Mappings.
            -- See `:help vim.lsp.*` for documentation on
            -- any of the below functions.
            local bufopts = { noremap=true, silent=true, buffer=bufnr }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            vim.keymap.set(
              'n',
              '<space>wa',
              vim.lsp.buf.add_workspace_folder, bufopts
            )
            vim.keymap.set(
              'n',
              '<space>wr',
              vim.lsp.buf.remove_workspace_folder,
              bufopts
            )
            vim.keymap.set(
              'n',
              '<space>wl',
              function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
              end,
              bufopts
            )
            vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
            vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
          end

        ${
          writeIfElse cfg.autocompletion.enable ''
            -- Add additional capabilities supported by nvim-cmp.
            local capabilities = require('cmp_nvim_lsp').update_capabilities(
              vim.lsp.protocol.make_client_capabilities()
            )

            -- Custom on_attach funciton for buffer-specific keybindings.
            local on_attach = function(client, bufnr)
            end
          '' ''
            -- Use standard Neovim lsp capabilities.
            local capabilities = vim.lsp.protocol.make_client_capabilities()
          ''
        }

          -- Enable some language servers with the additional
          -- completion capabilities offered by nvim-cmp.
          local servers = {'clangd', 'rust_analyzer'}


          for _, lsp in ipairs(servers) do
            require('lspconfig')[lsp].setup({
              capabilities = capabilities,
              on_attach = on_attach,
            })
          end
      '';
    };
}
