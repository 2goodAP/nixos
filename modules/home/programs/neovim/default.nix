{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./langtools
    ./autocompletion.nix
    ./filetype.nix
    ./git.nix
    ./motion.nix
    ./statusline.nix
    ./telescope.nix
    ./treesitter.nix
    ./ui.nix
  ];

  options.tgap.home.programs.neovim = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "neovim";
    alias = mkEnableOption "vi and vim aliases";
  };

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = cfg.alias;
        vimAlias = cfg.alias;
        vimdiffAlias = cfg.alias;
        withPython3 = true;
        withNodeJs = true;

        extraPackages = with pkgs; [
          ghostscript
          graphicsmagick-imagemagick-compat
          inotify-tools
          mermaid-cli
          tectonic
        ];

        extraLuaConfig = ''
          -- Base Configuration
          ${builtins.readFile ./lua/init.lua}
        '';

        plugins = with pkgs.vimPlugins; [
          lz-n

          {
            plugin = nvim-window-picker;
            optional = true;
            type = "lua";
            config = ''
              require("lz.n").load({
                "nvim-window-picker",
                event = "DeferredUIEnter",
                after = function()
                  require("window-picker").setup({
                    hint = "floating-big-letter",
                    picker_config = {handle_mouse_click = true},
                    show_prompt = false,
                    filter_rules = {
                      autoselect_one = true,
                      include_current_win = true,
                      -- filter using buffer options
                      bo = {
                        -- if file type is one of following, window will be ignored
                        filetype = {
                          "neo-tree",
                          "neo-tree-popup",
                          "notify",
                          "snacks_notif",
                        },
                        -- if buffer type is one of following, window will be ignored
                        buftype = {"terminal", "quickfix"},
                      },
                    },
                  })
                end,
              })
            '';
          }

          {
            plugin = snacks-nvim;
            type = "lua";
            config = ''
              require("lz.n").load({
                "snacks.nvim",
                priority = 1000,
                lazy = false,
                after = function()
                  require("snacks").setup({
                    bigfile = {enabled = true},
                    dufdelete = {enabled = true},
                    dashboard = {
                      enabled = true,
                      sections = {
                        {section = "header"},
                        {section = "keys", gap = 1, padding = 2},
                        {
                          icon = " ",
                          title = "Recent Files",
                          section = "recent_files",
                          indent = 2,
                          padding = 2,
                        },
                        {
                          icon = " ",
                          title = "Projects",
                          section = "projects",
                          indent = 2,
                          padding = 2,
                        },
                      },
                    },
                    debug = {enabled = true},
                    dim = {enabled = true},
                    gitbrowse = {enabled = true},
                    image = {enabled = true},
                    indent = {
                      enabled = true,
                      chunk = {
                        enabled = true,
                        char = {
                          corner_top = "╭",
                          corner_bottom = "╰",
                          arrow = "🢖",
                        },
                      },
                    },
                    input = {enabled = true},
                    layout = {enabled = true},
                    profiler = {enabled = true},
                    quickfile = {enabled = true},
                    rename = {enabled = true},
                    scope = {enabled = true},
                    scratch = {enabled = true},
                    statuscolumn = {
                      enabled = true,
                      folds = {open = true, git_hl = true},
                    },
                    terminal = {enabled = true},
                    toggle = {enabled = true},
                    win = {enabled = true},
                    words = {enabled = true},
                    zen = {enabled = true},
                  })

                  -- Replace `vim.ui.input` with `Snacks.input`
                  vim.ui.input = Snacks.input

                  -- Snacks keymaps
                  vim.keymap.set(
                    "n", "<leader>ab",
                    "<Cmd>silent! lua Snacks.bufdelete.delete("
                    .. 'vim.api.nvim_win_get_buf(require("window-picker").pick_window())'
                    .. ")<CR>",
                    {desc = "Snacks select a buffer and delete it"}
                  )

                  vim.keymap.set(
                    "n", "<leader>ag", Snacks.gitbrowse.open,
                    {desc = "Snacks open current git repo in the browser"}
                  )

                  Snacks.toggle.diagnostics():map(
                    "<leader>aa",
                    {desc = "Snacks toggle diagnostics"}
                  )

                  Snacks.toggle.dim():map(
                    "<leader>ad",
                    {desc = "Snacks toggle dimming everything except the active scope"}
                  )

                  Snacks.toggle.indent():map(
                    "<leader>aI",
                    {desc = "Snacks toggle indent"}
                  )

                  Snacks.toggle.inlay_hints():map(
                    "<leader>ai",
                    {desc = "Snacks toggle inlay hints"}
                  )

                  Snacks.toggle.line_number():map(
                    "<leader>au",
                    {desc = "Snacks toggle line number"}
                  )

                  Snacks.toggle.profiler():map(
                    "<leader>ap",
                    {desc = "Snacks toggle profiler"}
                  )

                  Snacks.toggle.profiler_highlights():map(
                    "<leader>ah",
                    {desc = "Snacks toggle profiler highlights"}
                  )

                  Snacks.toggle.treesitter():map(
                    "<leader>aT",
                    {desc = "Snacks toggle treesitter"}
                  )

                  Snacks.toggle.words():map(
                    "<leader>aw",
                    {desc = "Snacks toggle words"}
                  )

                  Snacks.toggle.zen():map(
                    "<leader>an",
                    {desc = "Snacks toggle zen mode"}
                  )

                  Snacks.toggle.zoom():map(
                    "<leader>am",
                    {desc = "Snacks toggle fullscreen zoom"}
                  )

                  vim.keymap.set(
                    "n", "<leader>ar", Snacks.rename.rename_file,
                    {desc = "Snacks rename the current buffer's file"}
                  )

                  vim.keymap.set(
                    "n", "<leader>as", Snacks.scratch.open,
                    {desc = "Snacks toggle scratch buffer"}
                  )

                  vim.keymap.set(
                    "n", "<leader>ae", Snacks.scratch.select,
                    {desc = "Snacks select scratch buffer"}
                  )

                  vim.keymap.set("n", "<leader>at", function()
                    Snacks.terminal("exec nu -li", {
                      cwd = vim.fn.expand("%:p:h"),
                      interactive = true,
                    })
                  end, { desc = "Snacks open terminal" })

                  vim.keymap.set("n", "<leader>aj", function()
                      Snacks.words.jump(vim.v.count1)
                  end, {desc = "Snacks jump to next LSP reference"})

                  vim.keymap.set("n", "<leader>aJ", function()
                      Snacks.words.jump(-vim.v.count1)
                  end, {desc = "Snacks jump to prev LSP reference"})
                end,
              })
            '';
          }
        ];
      };
    };
}
