{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.home.programs.neovim.git.enable = let
    inherit (lib) mkEnableOption;
  in
    mkEnableOption "git-related plugins" // {default = true;};

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf;
  in
    mkIf (cfg.enable && cfg.git.enable) {
      programs.neovim = {
        plugins = with pkgs.vimPlugins; [
          {
            plugin = gitsigns-nvim;
            optional = true;
            type = "lua";
            config = ''
              require("lz.n").load({
                "gitsigns.nvim",
                event = "BufWinEnter",
                after = function()
                  local gitsigns = require("gitsigns")

                  gitsigns.setup({
                    on_attach = function(bufnr)
                      local gs_opts = {buffer = bufnr}

                      vim.keymap.set("n", "<leader>gn", function()
                        if vim.wo.diff then
                          vim.cmd.normal({"<leader>gn", bang = true})
                        else
                          gitsigns.nav_hunk("next")
                        end
                      end, vim.tbl_deep_extend("force", gs_opts, {
                        desc = "Gitsigns navigate to next hunk",
                      }))

                      vim.keymap.set("n", "<leader>gp", function()
                        if vim.wo.diff then
                          vim.cmd.normal({"<leader>gp", bang = true})
                        else
                          gitsigns.nav_hunk("prev")
                        end
                      end, vim.tbl_deep_extend("force", gs_opts, {
                        desc = "Gitsigns navigate to previous hunk",
                      }))

                      vim.keymap.set(
                        "n", "<leader>gs", gitsigns.stage_hunk,
                        vim.tbl_deep_extend("force", gs_opts,
                          {desc = "Gitsigns stage current hunk"})
                      )

                      vim.keymap.set(
                        "n", "<leader>gr", gitsigns.reset_hunk,
                        vim.tbl_deep_extend("force", gs_opts,
                          {desc = "Gitsigns reset current hunk"})
                      )

                      vim.keymap.set("v", "<leader>gs", function()
                        gitsigns.stage_hunk({vim.fn.line("."), vim.fn.line("v")})
                      end, vim.tbl_deep_extend("force", gs_opts, {
                        desc = "Gitsigns stage current hunk",
                      }))

                      vim.keymap.set("n", "<leader>gr", function()
                        gitsigns.reset_hunk({vim.fn.line("."), vim.fn.line("v")})
                      end, vim.tbl_deep_extend("force", gs_opts, {
                        desc = "Gitsigns reset current hunk",
                      }))

                      vim.keymap.set(
                        "n", "<leader>gS", gitsigns.stage_buffer,
                        vim.tbl_deep_extend("force", gs_opts,
                          {desc = "Gitsigns stage current buffer"})
                      )

                      vim.keymap.set(
                        "n", "<leader>gR", gitsigns.reset_buffer,
                        vim.tbl_deep_extend("force", gs_opts,
                          {desc = "Gitsigns reset current buffer"})
                      )

                      vim.keymap.set(
                        "n", "<leader>gp", gitsigns.preview_hunk,
                        vim.tbl_deep_extend("force", gs_opts,
                          {desc = "Gitsigns preview current hunk"})
                      )

                      vim.keymap.set(
                        "n", "<leader>gi", gitsigns.preview_hunk_inline,
                        vim.tbl_deep_extend("force", gs_opts,
                          {desc = "Gitsigns preview current hunk in a popup"})
                      )

                      vim.keymap.set("n", "<leader>gb", function()
                        gitsigns.blame_line({full = true})
                      end, vim.tbl_deep_extend("force", gs_opts, {
                        desc = "Gitsigns blame line full",
                      }))

                      vim.keymap.set(
                        "n", "<leader>gl", gitsigns.toggle_current_line_blame,
                        vim.tbl_deep_extend("force", gs_opts,
                          {desc = "Gitsigns toggle inline virtual text blame"})
                      )

                      vim.keymap.set(
                        "n", "<leader>gc", ":Gitsigns change_base ",
                        vim.tbl_deep_extend("force", gs_opts,
                          {desc = "Gitsigns change the revision for the signs"})
                      )

                      vim.keymap.set(
                        "n", "<leader>gd", gitsigns.diffthis,
                        vim.tbl_deep_extend("force", gs_opts,
                          {desc = "Gitsigns diff current buffer with the index"})
                      )

                      vim.keymap.set(
                        "n", "<leader>gD", ":Gitsigns diffthis ",
                        vim.tbl_deep_extend("force", gs_opts,
                          {desc = "Gitsigns diff current buffer with a revision"})
                      )

                      vim.keymap.set(
                        "n", "<leader>gw", gitsigns.toggle_word_diff,
                        vim.tbl_deep_extend("force", gs_opts,
                          {desc = "Gitsigns toggle inline word diff"})
                      )

                      vim.keymap.set(
                        "n", "<leader>gq", gitsigns.setqflist,
                        vim.tbl_deep_extend("force", gs_opts, {
                          desc = "Gitsigns set quickfix list "
                            .. "for current buffer with changes",
                        })
                      )

                      vim.keymap.set("n", "<leader>gQ", function()
                        gitsigns.setqflist("all")
                      end, vim.tbl_deep_extend("force", gs_opts, {
                        desc = "Gitsigns set quickfix list for all buffers with changes",
                      }))

                      vim.keymap.set(
                        {"o", "x"}, "ih", gitsigns.select_hunk,
                        vim.tbl_deep_extend("force", gs_opts,
                          {desc = "Gitsigns select current hunk"})
                      )

                      vim.keymap.set(
                        "n", "<leader>gh", ":Gitsigns show ",
                        vim.tbl_deep_extend("force", gs_opts, {
                          desc = "Gitsigns show the selected revision of current buffer",
                        })
                      )
                    end,
                  })
                end,
              })
            '';
          }

          plenary-nvim
          diffview-nvim
          {
            plugin = neogit;
            optional = true;
            type = "lua";
            config = ''
              require("lz.n").load({
                "neogit",
                keys = {
                  {
                    mode = "n", "<leader>gg", function()
                      require("neogit").open({cwd = "%:p:h", kind = "floating"})
                    end, desc = "Open Neogit popup in the repo of the current file",
                  },
                },
                after = function() require("neogit").setup({}) end,
              })
            '';
          }
        ];
      };
    };
}
