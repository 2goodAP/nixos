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
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.expandtab = true

-- Highlight the current cursor line.
vim.opt.cursorline = true

-- Display column break at 90 characters.
vim.opt.colorcolumn = "90"

-- Split manipulation.
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Enable blinking cursor
vim.opt.guicursor = {
  "i-ci:ver25-blinkwait700-blinkon250-blinkoff400",
}

-- Hide netrw directory listing banner.
vim.g.netrw_banner = false

-- Remove "How-to disable mouse" entry from popup menu
vim.cmd.aunmenu({ "PopUp.-2-", mods = { emsg_silent = true, silent = true } })
vim.cmd.aunmenu({
  [[PopUp.How-to\ disable\ mouse]],
  mods = { emsg_silent = true, silent = true },
})

-- Configure fold options and set foldmethod and foldexpr (if necessary)
vim.o.foldenable = false
vim.o.foldcolumn = "1"
vim.o.fillchars = "eob: ,fold: ,foldsep: ,foldopen:,foldclose:"

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("config.fold", {}),
  desc = "Use the appropriate foldmethod & foldexpr"
    .. " depending on lsp and treesitter availability",
  callback = function(aopts)
    vim.schedule(function()
      local winnr = vim.api.nvim_get_current_win()

      if vim.lsp.buf_is_attached(aopts.buf) then
        vim.wo[winnr][0].foldmethod = "expr"
        vim.wo[winnr][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
      elseif vim.treesitter.language.get_lang(vim.bo.filetype) then
        vim.wo[winnr][0].foldmethod = "expr"
        vim.wo[winnr][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
      else
        vim.wo[winnr][0].foldmethod = "indent"
      end
    end)
  end,
})

-- ----------- --
-- Keybindings --
-- ----------- --

-- Enable mousemoveevent
vim.opt.mousemoveevent = true

-- Map <leader> to <space> and <localleader> to ",".
vim.g.mapleader = " "
vim.g.maplocalleader = "-"

-- Terminal mode
-- -------------
-- "Escaping" to normal mode in terminal mode
vim.keymap.set(
  "t",
  "<A-;>",
  [[<C-\><C-n>]],
  { desc = "Escape to normal mode from Terminal mode" }
)

vim.keymap.set(
  "t",
  "<A-l>",
  [[<C-\><C-n>gt]],
  { desc = "Navigate to right tab in Terminal mode" }
)

vim.keymap.set(
  "t",
  "<A-h>",
  [[<C-\><C-n>gT]],
  { desc = "Navigate to left tab in Terminal mode" }
)

-- Normal mode
-- -----------
vim.keymap.set(
  "n",
  "<C-h>",
  "<C-w>h",
  { desc = "Navigate to left split in Normal mode" }
)

vim.keymap.set(
  "n",
  "<C-j>",
  "<C-w>j",
  { desc = "Navigate split downward in Normal mode" }
)

vim.keymap.set(
  "n",
  "<C-k>",
  "<C-w>k",
  { desc = "Navigate to right split in Normal mode" }
)

vim.keymap.set(
  "n",
  "<C-l>",
  "<C-w>l",
  { desc = "Navigate to left split in Normal mode" }
)

vim.keymap.set(
  "n",
  "<C-m>",
  "<C-w>w",
  { desc = "Navigate to floating window in Normal mode" }
)

vim.keymap.set("n", "<A-l>", "gt", { desc = "Navigate to right tab in Normal mode" })

vim.keymap.set("n", "<A-h>", "gT", { desc = "Navigate to left tab in Normal mode" })

-- Insert/Operator/Visual modes
-- ------------------------------------
vim.keymap.set(
  { "i", "o", "v" },
  "<C-h>",
  "<ESC><C-w>h",
  { desc = "Navigate to left split in Command/Insert/Operator/Visual modes" }
)

vim.keymap.set(
  { "i", "o", "v" },
  "<C-j>",
  "<ESC><C-w>j",
  { desc = "Navigate to down split in Command/Insert/Operator/Visual modes" }
)

vim.keymap.set(
  { "i", "o", "v" },
  "<C-k>",
  "<ESC><C-w>k",
  { desc = "Navigate to up split in Command/Insert/Operator/Visual modes" }
)

vim.keymap.set(
  { "i", "o", "v" },
  "<C-l>",
  "<ESC><C-w>l",
  { desc = "Navigate to right split in Command/Insert/Operator/Visual modes" }
)

vim.keymap.set(
  { "i", "o", "v" },
  "<C-m>",
  "<ESC><C-w>w",
  { desc = "Navigate to floating window in Command/Insert/Operator/Visual modes" }
)

vim.keymap.set(
  { "i", "o", "v" },
  "<A-l>",
  "<ESC>gt",
  { desc = "Navigate to right tab in Command/Insert/Operator/Visual modes" }
)

vim.keymap.set(
  { "i", "o", "v" },
  "<A-h>",
  "<ESC>gT",
  { desc = "Navigate to left tab in Command/Insert/Operator/Visual modes" }
)
