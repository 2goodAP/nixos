{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./cpp.nix
    ./haskell.nix
    ./lua.nix
    ./nix.nix
    ./python.nix
    ./rust.nix
    ./typescript.nix
  ];

  options.tgap.system.programs.neovim.langtools = let
    inherit (lib) mkIf mkEnableOption mkOption optionals types;
  in {
    languages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        The extra language servers to be installed. Supported languages are
        'cpp', 'haskell', 'lua', 'nix', 'python', 'rust', 'typescript'.
      '';
    };

    dap.enable = mkEnableOption "Whether or not to enable dap-related plugins.";

    lsp = {
      enable = mkEnableOption "Whether or not to enable lsp-related plugins.";

      lspsaga.enable = mkEnableOption "Whether or not to enable lspsaga.nvim.";

      lspSignature.enable =
        mkEnableOption "Whether or not to enable lsp-signature.nvim.";

      ufo.enable = mkEnableOption "Whether or not to enable ufo.nvim.";
    };
  };

  config = let
    cfg = config.tgap.system.programs.neovim.langtools;
    inherit (lib) mkIf mkMerge optionals;
  in
    mkMerge [
      (mkIf cfg.dap.enable {
        tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.nvim-dap];
      })

      (mkIf cfg.lsp.enable {
        tgap.system.programs.neovim.startPackages =
          [pkgs.vimPlugins.nvim-lspconfig]
          ++ (
            optionals cfg.lsp.lspsaga.enable [pkgs.vimPlugins.lspsaga-nvim]
          )
          ++ (
            optionals cfg.lsp.lspSignature.enable [pkgs.vimPlugins.lsp_signature-nvim]
          )
          ++ (
            optionals cfg.lsp.ufo.enable [pkgs.vimPlugins.nvim-ufo]
          );

        tgap.system.programs.neovim.luaExtraConfig = let
          writeIf = cond: msg:
            if cond
            then msg
            else "";
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

          ${writeIf cfg.lsp.lspsaga.enable ''
            require('lspsaga').setup({})
          ''}

          ${writeIf cfg.lsp.lspSignature.enable ''
            require "lsp_signature".setup({
              bind = true, -- This is mandatory.
              handler_opts = {
                border = "rounded"
              }
            })
          ''}

          ${writeIf cfg.lsp.ufo.enable ''
            vim.o.foldcolumn = '1' -- '0' is not bad
            vim.o.foldlevel = 99 -- Using ufo provider need a large value
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            -- Using ufo provider need remap `zR` and `zM`.
            vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
            vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

            -- Using nvim lsp as LSP client
            -- Tell the server the capability of foldingRange,
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true
            }
            local servers = require("lspconfig").util.available_servers()
            for _, ls in ipairs(servers) do
                require('lspconfig')[ls].setup({
                    capabilities = capabilities
                })
            end
            require('ufo').setup()
          ''}
        '';
      })
    ];
}
