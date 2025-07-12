{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.filetype = let
    inherit (lib) mkEnableOption;
  in {
    markdown.enable = mkEnableOption "markdown rendering plugins" // {default = true;};
    norg.enable = mkEnableOption "norg mode and related plugins" // {default = true;};
    sql.enable = mkEnableOption "sql database connection plugins" // {default = true;};
  };

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf mkMerge;
  in
    mkIf cfg.enable (mkMerge [
      (mkIf cfg.filetype.markdown.enable {
        programs.neovim = {
          extraPackages = [pkgs.python3Packages.pylatexenc];

          plugins = with pkgs.vimPlugins; [
            mini-icons
            {
              plugin = render-markdown-nvim;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "render-markdown.nvim",
                  ft = "markdown",
                  after = function()
                    local render_markdown = require("render-markdown")

                    render_markdown.setup({
                      on = {
                        attach = function()
                          vim.keymap.set(
                            "n", "<leader>m", function()
                              render_markdown.toggle()
                            end, {desc = "Toggle rendering of all markdown buffers"}
                          )

                          vim.keymap.set(
                            "n", "<leader>M", function()
                              render_markdown.buf_toggle()
                            end, {desc = "Toggle rendering of current markdown buffer"}
                          )
                        end,
                      },
                      completions = {lsp = {enabled = true}},
                    })
                  end,
                })
              '';
            }
          ];
        };
      })

      (mkIf cfg.filetype.norg.enable {
        programs.neovim.plugins = with pkgs.vimPlugins; [
          plenary-nvim
          {
            plugin = neorg-telescope;
            type = "lua";
            config = ''
              require("lz.n").load({
                "neorg-telescope",
                lazy = false,
              })
            '';
          }
          {
            plugin = neorg;
            type = "lua";
            config = ''
              require("lz.n").load({
                "neorg",
                lazy = false,
                after = function()
                  require("neorg").setup({
                    load = {
                      ["core.defaults"] = {}, -- Loads default behaviour
                      ["core.concealer"] = {}, -- Adds pretty icons to your documents
                      ["core.dirman"] = {}, -- Manages Neorg workspaces
                      ["core.integrations.telescope"] = {}, -- Enables telescope integration

                      -- Disable default keybinds
                      ["core.keybinds"] = {config = {default_keybinds = false}}
                    },
                  })

                  vim.keymap.set(
                    "n", "<leader>nn", "<Plug>(neorg.dirman.new-note)",
                    {desc = "Neorg create a new .norg file for taking notes"}
                  )

                  vim.keymap.set(
                    "n", "<leader>nb", "<Cmd>Neorg toc<CR>",
                    {desc = "Neorg create a table of contents"}
                  )
                end,
              })
            '';
            runtime."ftplugin/norg.lua".text = ''
              -- Insert mode keymaps
              vim.keymap.set(
                "i", "<C-d>", "<Plug>(neorg.promo.demote)", {
                  buffer = true,
                  desc = "Neorg demote an object recursively",
                }
              )

              vim.keymap.set(
                "i", "<C-t>", "<Plug>(neorg.promo.promote)", {
                  buffer = true,
                  desc = "Neorg promote an object recursively",
                }
              )

              vim.keymap.set(
                "i", "<M-CR>", "<Plug>(neorg.itero.next-iteration)", {
                  buffer = true,
                  desc = "Neorg create an iteration of an item",
                }
              )

              vim.keymap.set(
                "i", "<M-d>", "<Plug>(neorg.tempus.insert-date.insert-mode)", {
                  buffer = true,
                  desc = "Neorg insert link to a date under the cursor",
                }
              )

              -- Normal mode keymaps
              vim.keymap.set(
                "n", "<leader>nd", "<Plug>(neorg.promo.demote)", {
                  buffer = true,
                  desc = "Neorg demote an object non-recursively",
                }
              )

              vim.keymap.set(
                "n", "<leader>nD", "<Plug>(neorg.promo.demote.nested)", {
                  buffer = true,
                  desc = "Neorg demote an object recursively",
                }
              )

              vim.keymap.set(
                "n", "<leader>ny", "<Plug>(neorg.qol.todo-items.todo.task-cycle)", {
                  buffer = true,
                  desc = "Neorg cycle task under the cursor between select few states",
                }
              )

              vim.keymap.set(
                "n", "<leader>nh", "<Plug>(neorg.esupports.hop.hop-link)", {
                  buffer = true,
                  desc = "Neorg hop to destination for the link under the cursor",
                }
              )

              vim.keymap.set(
                "n", "<leader>nm", "<Plug>(neorg.looking-glass.magnify-code-block)", {
                  buffer = true,
                  desc = "Neorg magnify a code block to a separate buffer",
                }
              )

              vim.keymap.set(
                "n", "<leader>ne", "<Plug>(neorg.tempus.insert-date)", {
                  buffer = true,
                  desc = "Neorg insert link to a date at the given position",
                }
              )

              vim.keymap.set(
                "n", "<leader>nv", "<Plug>(neorg.pivot.list.invert)", {
                  buffer = true,
                  desc = "Neorg invert all items in a list",
                }
              )

              vim.keymap.set(
                "n", "<leader>nt", "<Plug>(neorg.pivot.list.toggle)", {
                  buffer = true,
                  desc = "Neorg toggle a list between ordered and unordered",
                }
              )

              vim.keymap.set(
                "n", "<leader>na", "<Plug>(neorg.qol.todo-items.todo.task-ambiguous)", {
                  buffer = true,
                  desc = "Neorg mark the task under the cursor as ambiguous",
                }
              )

              vim.keymap.set(
                "n", "<leader>nc", "<Plug>(neorg.qol.todo-items.todo.task-cancelled)", {
                  buffer = true,
                  desc = "Neorg mark the task under the cursor as cancelled",
                }
              )

              vim.keymap.set(
                "n", "<leader>no", "<Plug>(neorg.qol.todo-items.todo.task-done)", {
                  buffer = true,
                  desc = "Neorg mark the task under the cursor as done",
                }
              )

              vim.keymap.set(
                "n", "<leader>nl", "<Plug>(neorg.qol.todo-items.todo.task-on-hold)", {
                  buffer = true,
                  desc = "Neorg mark the task under the cursor as on-hold",
                }
              )

              vim.keymap.set(
                "n", "<leader>ni", "<Plug>(neorg.qol.todo-items.todo.task-important)", {
                  buffer = true,
                  desc = "Neorg mark the task under the cursor as important",
                }
              )

              vim.keymap.set(
                "n", "<leader>ng", "<Plug>(neorg.qol.todo-items.todo.task-pending)", {
                  buffer = true,
                  desc = "Neorg mark the task under the cursor as pending",
                }
              )

              vim.keymap.set(
                "n", "<leader>nr", "<Plug>(neorg.qol.todo-items.todo.task-recurring)", {
                  buffer = true,
                  desc = "Neorg mark the task under the cursor as recurring",
                }
              )

              vim.keymap.set(
                "n", "<leader>nu", "<Plug>(neorg.qol.todo-items.todo.task-undone)", {
                  buffer = true,
                  desc = "Neorg mark the task under the cursor as undone",
                }
              )

              vim.keymap.set(
                "n", "<leader>nV", "<Plug>(neorg.esupports.hop.hop-link.vsplit)", {
                  buffer = true,
                  desc = "Neorg hop to destination for the link in a vsplit",
                }
              )

              vim.keymap.set(
                "n", "<leader>nH", "<Plug>(neorg.esupports.hop.hop-link.tab-drop)", {
                  buffer = true,
                  desc = "Neorg hop to destination for the link in a new tab",
                }
              )

              vim.keymap.set(
                "n", "<leader>np", "<Plug>(neorg.promo.promote)", {
                  buffer = true,
                  desc = "Neorg promote an object non-recursively",
                }
              )

              vim.keymap.set(
                "n", "<leader>nP", "<Plug>(neorg.promo.promote.nested)", {
                  buffer = true,
                  desc = "Neorg promote an object recursively",
                }
              )

              -- Visual mode keymaps
              vim.keymap.set(
                "v", "<leader>nd", "<Plug>(neorg.promo.demote.range)", {
                  buffer = true,
                  desc = "Neorg demote objects in range",
                }
              )

              vim.keymap.set(
                "v", "<leader>np", "<Plug>(neorg.promo.promote.range)", {
                  buffer = true,
                  desc = "Neorg promote objects in range",
                }
              )
            '';
          }
        ];
      })

      (mkIf cfg.filetype.sql.enable {
        programs.neovim.plugins = with pkgs.vimPlugins; [
          {
            plugin = vim-dadbod;
            optional = true;
            type = "lua";
            config = ''
              require("lz.n").load({
                "vim-dadbod",
                cmd = "DB",
                keys = {
                  {
                    mode = n, "<leader>qd", ":DB ",
                    desc = "DB add a connection URL using cmdline",
                  },
                },
              })
            '';
          }

          {
            plugin = vim-dadbod-completion;
            optional = true;
            type = "lua";
            config = let
              ft = ''"sql", "mysql", "plsql"'';
            in ''
              require("lz.n").load({
                "vim-dadbod-completion",
                ft = {${ft}},
                after = function()
                  -- DBCompletion keymaps
                  vim.api.nvim_create_autocmd("FileType", {
                    pattern = {${ft}},
                    desc = "Create filetype keymaps for DBCompletion",
                    callback = function()
                      vim.schedule(function()
                        vim.keymap.set(
                          "n", "<leader>qc", "<Cmd>DBCompletionClearCache<CR>", {
                            buffer = vim.api.nvim_get_current_buf(),
                            desc = "DBCompletion clear database cache",
                          }
                        )
                      end)
                    end,
                  })
                end,
              })
            '';
          }

          {
            plugin = vim-dadbod-ui;
            optional = true;
            type = "lua";
            config = ''
              require("lz.n").load({
                "vim-dadbod-ui",
                cmd = {
                  "DBUI",
                  "DBUIToggle",
                  "DBUIAddConnection",
                  "DBUIFindBuffer",
                },
                keys = {
                  {
                    mode = "n", "<leader>qt", "<Cmd>DBUIToggle<CR>",
                    desc = "DBUI toggle",
                  },
                  {
                    mode = "n", "<leader>qa", "<Cmd>DBUIAddConnection<CR>",
                    desc = "DBUI provide URL for a new connection",
                  },
                  {
                    mode = "n", "<leader>qf", "<Cmd>DBUIFindBuffer<CR>",
                    desc = "DBUI find buffer",
                  },
                  {
                    mode = "n", "<leader>qr", "<Cmd>DBUIRenameBuffer<CR>",
                    desc = "DBUI rename buffer",
                  },
                },
                after = function()
                  vim.g.db_ui_use_nerd_fonts = 1

                  -- Change the env vars that will be read
                  vim.g.db_ui_env_variable_url = "DATABASE_URL"
                  vim.g.db_ui_env_variable_name = "DATABASE_NAME"

                  -- DBUI keymaps
                  vim.api.nvim_create_autocmd("FileType", {
                    pattern = {"sql"},
                    desc = "Create filetype keymaps for DBUI",
                    callback = function()
                      vim.schedule(function()
                        vim.keymap.set(
                          "n", "<leader>qj", "<Plug>(DBUI_JumpToForeignKey)", {
                            buffer = vim.api.nvim_get_current_buf(),
                            desc = "DBUI jump to foreign key",
                          }
                        )
                      end)
                    end,
                  })
                end,
              })
            '';
          }
        ];
      })
    ]);
}
