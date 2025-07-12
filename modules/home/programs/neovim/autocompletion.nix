{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.autocompletion.enable = let
    inherit (lib) mkEnableOption;
  in
    mkEnableOption "autocompletion-related plugins" // {default = true;};

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf optionals optionalString;
  in
    mkIf (cfg.enable && cfg.autocompletion.enable) {
      programs.neovim = let
        gitEnabled = cfg.git.enable;
        sqlEnabled = cfg.filetype.sql.enable;

        luaEnabled =
          cfg.langtools.languageServers.enable
          && builtins.elem "lua" cfg.langtools.languages;
        tsEnabled =
          cfg.langtools.languageServers.enable
          && builtins.elem "typescript" cfg.langtools.languages;
      in {
        extraLuaPackages = luaPkgs: [luaPkgs.jsregexp];

        extraPackages = with pkgs; [
          ripgrep
          wordnet
        ];

        plugins = with pkgs.vimPlugins;
          [
            plenary-nvim
            {
              plugin = blink-cmp-dictionary;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "blink-cmp-dictionary",
                  lazy = true,
                })
              '';
            }
            {
              plugin = blink-cmp-spell;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "blink-cmp-spell",
                  lazy = true,
                })
              '';
            }
            {
              plugin = friendly-snippets;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "friendly-snippets",
                  lazy = true,
                })
              '';
            }
            {
              plugin = luasnip;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "luasnip",
                  lazy = true,
                })
              '';
            }
            {
              plugin = blink-cmp;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "blink.cmp",
                  event = "BufWinEnter",

                  before = function()
                    require("lz.n").trigger_load("blink-cmp-dictionary")
                    require("lz.n").trigger_load("blink-cmp-spell")
                    require("lz.n").trigger_load("friendly-snippets")
                    require("lz.n").trigger_load("luasnip")
                ${
                  optionalString gitEnabled ''
                    require("lz.n").trigger_load("blink-cmp-conventional-commits")
                    require("lz.n").trigger_load("blink-cmp-git")
                  ''
                }
                  end,

                  after = function()
                    -- Selectively disable `vim.fn.spellsuggest` for
                    --  really slow languages, such as German
                    --- @type table<integer, boolean?>
                    local spell_enabled_cache = {}

                    vim.api.nvim_create_autocmd("OptionSet", {
                      group = vim.api.nvim_create_augroup("blink_cmp_spell", {}),
                      desc = "Reset the cache for enabling the spell source for blink.cmp",
                      pattern = "spelllang",
                      callback = function()
                        spell_enabled_cache[vim.fn.bufnr()] = nil
                      end,
                    })

                    require("blink.cmp").setup({
                      snippets = {preset = "luasnip"},

                      sources = {
                        default = {
                          "lsp", "path", "snippets", "buffer", "dictionary", "spell",
                          ${optionalString cfg.git.enable ''"git", "conventional_commits",''}
                        },

                        per_filetype = {
                ${
                  optionalString luaEnabled ''
                    lua = {"lazydev", inherit_defaults = true},
                  ''
                }
                ${
                  optionalString tsEnabled ''
                    javascript = {"npm", inherit_defaults = true},
                    javascriptreact = {"npm", inherit_defaults = true},
                    typescript = {"npm", inherit_defaults = true},
                    typescriptreact = {"npm", inherit_defaults = true},
                  ''
                }
                ${
                  optionalString sqlEnabled ''
                    sql = {"dadbod", inherit_defaults = true},
                  ''
                }
                        },

                        providers = {
                          buffer = {
                            -- keep case of first char on buffer source
                            transform_items = function (a, items)
                              local keyword = a.get_keyword()
                              local correct, case
                              if keyword:match("^%l") then
                                correct = "^%u%l+$"
                                case = string.lower
                              elseif keyword:match("^%u") then
                                correct = "^%l+$"
                                case = string.upper
                              else
                                return items
                              end

                              -- avoid duplicates from the corrections
                              local seen = {}
                              local out = {}
                              for _, item in ipairs(items) do
                                local raw = item.insertText
                                if raw ~= nil and raw:match(correct) then
                                  local text = case(raw:sub(1,1)) .. raw:sub(2)
                                  item.insertText = text
                                  item.label = text
                                end
                                if not seen[item.insertText] then
                                  seen[item.insertText] = true
                                  table.insert(out, item)
                                end
                              end
                              return out
                            end
                          },
                ${
                  optionalString gitEnabled ''
                    conventional_commits = {
                      name = "Conventional Commits",
                      module = "blink-cmp-conventional-commits",
                      enabled = function()
                        return vim.bo.filetype == "gitcommit"
                      end,
                    },

                    git = {
                      module = "blink-cmp-git",
                      name = "Git",
                      -- only enable this source when filetype is
                      -- gitcommit, markdown, or "octo"
                      enabled = function()
                        return vim.tbl_contains(
                          {"octo", "gitcommit", "markdown"},
                          vim.bo.filetype
                        )
                      end,
                    },
                  ''
                }
                          dictionary = {
                            module = "blink-cmp-dictionary",
                            name = "Dict",
                            -- Make sure this is at least 2.
                            -- 3 is recommended
                            min_keyword_length = 3,
                            -- Limit number of items shown in completion menu
                            max_items = 5,
                            opts = {
                              dictionary_files = {
                                "${pkgs.hunspellDicts.en_AU-large}/share/hunspell/en_AU.dic",
                                "${pkgs.hunspellDicts.en_CA-large}/share/hunspell/en_CA.dic",
                                "${pkgs.hunspellDicts.en_GB-large}/share/hunspell/en_GB.dic",
                                "${pkgs.hunspellDicts.en_US-large}/share/hunspell/en_US.dic",
                              },
                            },
                          },
                          spell = {
                            name = "Spell",
                            module = "blink-cmp-spell",
                            enabled = function()
                              local bufnr = vim.fn.bufnr()
                              local enabled = spell_enabled_cache[bufnr]
                              if type(enabled) ~= "boolean" then
                                enabled = not vim.list_contains(
                                  vim.opt_local.spelllang:get(), "de"
                                )
                                spell_enabled_cache[bufnr] = enabled
                              end
                              return enabled
                            end,
                            opts = {
                              -- EXAMPLE: Only enable source in `@spell` captures,
                              -- and disable it in `@nospell` captures.
                              enable_in_context = function()
                                local curpos = vim.api.nvim_win_get_cursor(0)
                                local captures = vim.treesitter.get_captures_at_pos(
                                  0,
                                  curpos[1] - 1,
                                  curpos[2] - 1
                                )
                                local in_spell_capture = false
                                for _, cap in ipairs(captures) do
                                  if cap.capture == "spell" then
                                    in_spell_capture = true
                                  elseif cap.capture == "nospell" then
                                    return false
                                  end
                                end
                                return in_spell_capture
                              end,
                            },
                          },
                ${
                  optionalString luaEnabled ''
                    lazydev = {
                       name = "LazyDev",
                       module = "lazydev.integrations.blink",
                       -- optional - make lazydev completions top priority
                       -- (see `:h blink.cmp`)
                       score_offset = 100,
                     },
                  ''
                }
                ${
                  optionalString sqlEnabled ''
                    dadbod = {
                      name = "dadbod",
                      module = "vim_dadbod_completion.blink",
                     -- optional - make dadbod completions top priority
                     -- (see `:h blink.cmp`)
                     score_offset = 100,
                    },
                  ''
                }
                ${
                  optionalString tsEnabled ''
                    npm = {
                      name = "npm",
                      module = "blink-cmp-npm",
                      async = true,
                      -- optional - make blink-cmp-npm completions top priority
                      -- (see `:h blink.cmp`)
                      score_offset = 100,
                    },
                  ''
                }
                        },
                      },

                      -- It is recommended to put the "label" sorter as the
                      -- primary sorter for the spell source.
                      -- If you set use_cmp_spell_sorting to true,
                      -- you may want to skip this step.
                      fuzzy = {
                        sorts = {
                          function(a, b)
                            local sort = require("blink.cmp.fuzzy.sort")
                            if a.source_id == "spell" and b.source_id == "spell" then
                              return sort.label(a, b)
                            end
                          end,
                          -- This is the normal default order, which we fall back to
                          "score",
                          "kind",
                          "label",
                        },
                      },
                    })
                  end,
                })
              '';
            }
          ]
          ++ optionals cfg.git.enable [
            {
              plugin = blink-cmp-conventional-commits;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "blink-cmp-conventional-commits",
                  lazy = true,
                })
              '';
            }
            {
              plugin = blink-cmp-git;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "blink-cmp-git",
                  lazy = true,
                })
              '';
            }
          ]
          ++ optionals tsEnabled [
            {
              plugin = blink-cmp-npm-nvim;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "blink-cmp-npm.nvim",
                  ft = {
                    "javascript",
                    "javascriptreact",
                    "typescript",
                    "typescriptreact",
                  },
                })
              '';
            }
          ];
      };
    };
}
