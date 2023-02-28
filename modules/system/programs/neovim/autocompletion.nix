{
  config,
  lib,
  pkgs,
  ...
}: {
  options.machine.programs.neovim.autocompletion = let
    inherit (lib) mkEnableOption;
  in {
    enable =
      mkEnableOption "Whether or not to enable autocompletion-related plugins.";

    dictionary.enable =
      mkEnableOption "Whether or not to enable dictionary autocompletion.";

    snippets.enable = mkEnableOpton "Whether or not to enable code snippets.";
  };

  config = let
    cfg = config.machine.programs.neovim;
    inherit (lib) mkIf optionals;
  in
    mkIf cfg.autocompletion.enable {
      machine.programs.neovim.startPackages = with pkgs.vimPlugins;
        [
          cmp-buffer
          cmp-cmdline
          cmp-nvim-lua
          cmp-path
          nvim-cmp
        ]
        ++ (
          optionals cfg.autocompletion.dictionary.enable [pkgs.vimPlugins.cmp-dictionary]
        )
        ++ (
          optionals cfg.autocompletion.snippets.enable (with pkgs.vimPlugins; [
            luasnip
            cmp_luasnip
          ])
        )
        ++ (
          optionals cfg.lsp.enable (with pkgs.vimPlugins; [
            cmp-nvim-lsp
            cmp-nvim-lsp-signature-help
            cmp-nvim-lsp-document-symbol
          ])
        )
        ++ (
          optionals cfg.git.enable [pkgs.vimPlugins.cmp-git]
        );

      machine.programs.neovim.luaConfig = let
        writeIf = cond: msg:
          if cond
          then msg
          else "";
      in ''
        -- Set up nvim-cmp.
        local cmp = require('cmp')
        local luasnip = require('luasnip')

        cmp.setup({
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            -- Accept currently selected item. Set `select` to `false`
            -- to only confirm explicitly selected items.
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          }),

          snippet = {
            -- REQUIRED - you must specify a snippet engine
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },

          sources = cmp.config.sources({
        ${
          writeIf cfg.autocompletion.dictionary.enable ''
            {name = 'dictionary'},
          ''
        }
        ${
          writeIf cfg.lsp.enable ''
            {name = 'nvim_lsp'},
            {name = 'nvim_lsp_document_symbol'},
            {name = 'nvim_lsp_signature_help'},
          ''
        }
        ${
          writeIf cfg.autocompletion.snippets.enable ''
            {name = 'luasnip'},
          ''
        }
          }, {
            {name = 'buffer'},
          }),

          view = {
            entries = {name = 'custom', selection_order = 'near_cursor'}
          },

          window = {
            autocompletion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
          },
        })

        ${writeIf cfg.autocompletion.dictionary.enable ''
          require("cmp_dictionary").setup({
            dic = {
              spelllang = {
                -- Better config format for switching between languages.
                en = "${pkgs.hunspellDicts.en_US-large}/share/hunspell/en_US.dic",
              },
            },
          })

          -- Set up a command for switching languages.
          vim.api.nvim_create_user_command(
            'SwitchLang',
            function(opts)
              vim.opt.spelllang = opts.args
              vim.cmd('CmpDictionaryUpdate')
            end,
            {nargs = 1},
          )
        ''}

        ${writeIf cfg.git.enable ''
          -- Set configuration for 'gitcommit' filetype.
          cmp.setup.filetype('gitcommit', {
            sources = cmp.config.sources({
              { name = 'cmp_git' },
            }, {
              { name = 'buffer' },
            })
          })
        ''}

        -- Set configuration for 'lua' filetype.
        cmp.setup.filetype('lua', {
          sources = cmp.config.sources({
            {name = 'nvim_lua'},
          }, {
            {name = 'buffer'},
          })
        })

        -- Use buffer source for `/` and `?`.
        for _, v in pairs({'/', '?'})
          cmp.setup.cmdline(v, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
              {name = 'buffer'}
            },
            view = {
              entries = {name = 'wildmenu', separator = ' | '}
            },
          })
        end

        -- Use cmdline & path source for ':'.
        cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            {name = 'path'}
          }, {
            {name = 'cmdline'}
          }),
          view = {
            entries = {name = 'wildmenu', separator = ' | '}
          },
        })
      '';
    };
}
