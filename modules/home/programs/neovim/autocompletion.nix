{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.autocompletion = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "autocompletion-related plugins";
    dictionary.enable = mkEnableOption "dictionary autocompletion";
    snippets.enable = mkEnableOption "code snippets";
  };

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) getExe mkIf optionals optionalString;
  in
    mkIf (cfg.enable && cfg.autocompletion.enable) {
      programs.neovim = {
        extraLuaPackages = luaPkgs: [luaPkgs.jsregexp];

        plugins =
          (with pkgs.vimPlugins; [
            cmp-buffer
            cmp-cmdline
            cmp-nvim-lua
            cmp-path
            cmp-under-comparator
            nvim-cmp
          ])
          ++ optionals cfg.autocompletion.dictionary.enable (with pkgs.vimPlugins; [
            cmp-dictionary
            plenary-nvim
          ])
          ++ optionals cfg.autocompletion.snippets.enable (with pkgs.vimPlugins; [
            cmp_luasnip
            luasnip
          ])
          ++ optionals cfg.langtools.lsp.enable (with pkgs.vimPlugins; [
            cmp-nvim-lsp
            cmp-nvim-lsp-signature-help
            cmp-nvim-lsp-document-symbol
          ])
          ++ optionals cfg.git.enable [pkgs.vimPlugins.cmp-git];

        extraLuaConfig = ''
          -- Set up nvim-cmp.
          local cmp = require("cmp")
          ${optionalString cfg.autocompletion.snippets.enable ''
            local luasnip = require("luasnip")
          ''}

          cmp.setup({
            mapping = cmp.mapping.preset.insert({
              ["<C-b>"] = cmp.mapping.scroll_docs(-4),
              ["<C-f>"] = cmp.mapping.scroll_docs(4),
              ["<C-Space>"] = cmp.mapping.complete(),
              ["<C-e>"] = cmp.mapping.abort(),
              -- Accept currently selected item. Set `select` to `false`
              -- to only confirm explicitly selected items.
              ["<CR>"] = cmp.mapping.confirm({ select = true }),
              ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
          ${optionalString cfg.autocompletion.snippets.enable ''
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
          ''}
                else
                  fallback()
                end
              end, { "i", "s" }),
              ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
          ${optionalString cfg.autocompletion.snippets.enable ''
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
          ''}
                else
                  fallback()
                end
              end, { "i", "s" }),
            }),

          ${optionalString cfg.autocompletion.snippets.enable ''
            snippet = {
              -- REQUIRED - you must specify a snippet engine
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
          ''}

            sources = cmp.config.sources({
          ${
            optionalString cfg.autocompletion.dictionary.enable ''
              {
                name = "dictionary",
                keyword_length = 2,
              },
            ''
          }
          ${
            optionalString cfg.langtools.lsp.enable ''
              {name = "nvim_lsp"},
              {name = "nvim_lsp_document_symbol"},
              {name = "nvim_lsp_signature_help"},
            ''
          }
          ${
            optionalString cfg.autocompletion.snippets.enable ''
              {name = "luasnip"},
            ''
          }
            }, {
              {name = "buffer"},
            }),

            view = {
              entries = {name = "custom", selection_order = "near_cursor"}
            },

            window = {
              autocompletion = cmp.config.window.bordered(),
              documentation = cmp.config.window.bordered(),
            },

            sorting = {
              comparators = {
                cmp.config.compare.offset,
                cmp.config.compare.exact,
                cmp.config.compare.score,
                require("cmp-under-comparator").under,
                cmp.config.compare.kind,
                cmp.config.compare.sort_text,
                cmp.config.compare.length,
                cmp.config.compare.order,
              },
            },
          })

          ${optionalString cfg.autocompletion.dictionary.enable ''
            require("cmp_dictionary").setup({
              paths = {
                "${pkgs.hunspellDicts.en_AU-large}/share/hunspell/en_AU.dic",
                "${pkgs.hunspellDicts.en_CA-large}/share/hunspell/en_CA.dic",
                "${pkgs.hunspellDicts.en_GB-large}/share/hunspell/en_GB.dic",
                "${pkgs.hunspellDicts.en_US-large}/share/hunspell/en_US.dic",
              },
              exact_length = 2,
              first_case_insensitive = true,
              document = {
                enable = true,
                command = {"${getExe pkgs.wordnet}", "''${label}", "-over"},
              },
            })

            -- Set up a command for switching languages.
            vim.api.nvim_create_user_command(
              "SwitchLang",
              function(opts)
                vim.opt.spelllang = opts.args
                vim.cmd("CmpDictionaryUpdate")
              end,
              {nargs = 1}
            )
          ''}

          ${optionalString cfg.git.enable ''
            -- Set configuration for "gitcommit" filetype.
            cmp.setup.filetype("gitcommit", {
              sources = cmp.config.sources({
                { name = "cmp_git" },
              }, {
                { name = "buffer" },
              })
            })
          ''}

          -- Set configuration for "lua" filetype.
          cmp.setup.filetype("lua", {
            sources = cmp.config.sources({
              {name = "nvim_lua"},
            }, {
              {name = "buffer"},
            })
          })

          -- Use buffer source for `/` and `?`.
          for _, v in pairs({"/", "?"}) do
            cmp.setup.cmdline(v, {
              mapping = cmp.mapping.preset.cmdline(),
              sources = {
                {name = "buffer"}
              },
              view = {
                entries = {name = "wildmenu", separator = " | "}
              },
            })
          end

          -- Use cmdline & path source for ":".
          cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
              {name = "path"}
            }, {
              {name = "cmdline"}
            }),
            view = {
              entries = {name = "wildmenu", separator = " | "}
            },
          })
        '';
      };
    };
}
