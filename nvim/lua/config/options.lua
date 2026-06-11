-- options.lua — core editor behavior. No plugins referenced here.

-- Leader keys MUST be set before lazy.nvim loads so plugin mappings bind to
-- the intended leader. Space is the leader, comma is the local leader.
vim.g.mapleader = " "
vim.g.maplocalleader = ","

local opt = vim.opt

-- == Line numbers (hybrid) ===============================================
-- Absolute number on the current line + relative numbers above/below so that
-- motions like 10j / 8k are trivial to count.
opt.number = true
opt.relativenumber = true

-- == UI ===================================================================
opt.termguicolors = true       -- 24-bit color (needed by the theme)
opt.signcolumn = "yes"         -- always show sign column (no text shifting)
opt.cursorline = true          -- highlight current line
opt.scrolloff = 8              -- keep 8 lines of context above/below cursor
opt.sidescrolloff = 8
opt.wrap = false               -- don't wrap long lines
opt.linebreak = true           -- if wrap is on, break at word boundaries
opt.colorcolumn = "100"        -- visual guide at column 100
opt.showmode = false           -- mode is shown in the statusline instead
opt.cmdheight = 1
opt.pumheight = 12             -- max items in completion popup
opt.pumblend = 6               -- slight transparency on popup menu
opt.winblend = 0
opt.conceallevel = 0
opt.laststatus = 3             -- single global statusline
opt.splitright = true          -- vertical splits open to the right
opt.splitbelow = true          -- horizontal splits open below
opt.fillchars = { eob = " " }  -- hide ~ on empty lines

-- == Indentation ==========================================================
opt.expandtab = true           -- spaces, not tabs
opt.shiftwidth = 4             -- size of an indent
opt.tabstop = 4                -- a tab counts for 4 spaces
opt.softtabstop = 4
opt.smartindent = true
opt.autoindent = true
opt.breakindent = true         -- wrapped lines keep indentation

-- == Search ===============================================================
opt.ignorecase = true          -- case-insensitive search...
opt.smartcase = true           -- ...unless the query has uppercase
opt.hlsearch = true            -- highlight matches (clear with <Esc>)
opt.incsearch = true           -- show matches while typing

-- == Files / persistence ==================================================
opt.swapfile = false
opt.backup = false
opt.undofile = true            -- persistent undo across sessions
opt.undolevels = 10000
opt.updatetime = 250           -- faster CursorHold (diagnostics, gitsigns)
opt.timeoutlen = 400           -- which-key popup delay
opt.confirm = true             -- ask to save instead of failing :q

-- == Editing quality of life =============================================
opt.mouse = "a"                -- mouse works if you want it, but you won't need it

-- WSL clipboard: set provider BEFORE we decide on unnamedplus (below).
if vim.fn.has("wsl") == 1 and vim.fn.executable("win32yank.exe") == 1 then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end

-- System clipboard: only when a real provider exists. Without this, yank uses
-- the default register and you avoid "clipboard: no provider" on SSH servers.
local function clipboard_available()
  if vim.g.clipboard and vim.g.clipboard.copy then return true end
  if vim.fn.has("clipboard") ~= 1 then return false end
  return vim.fn.executable("xclip") == 1
    or vim.fn.executable("xsel") == 1
    or vim.fn.executable("wl-copy") == 1
    or vim.fn.executable("pbcopy") == 1
    or vim.fn.executable("clip") == 1
end
if clipboard_available() then
  opt.clipboard = "unnamedplus"
end
opt.completeopt = "menu,menuone,noselect"
opt.inccommand = "split"       -- live preview of :substitute
opt.virtualedit = "block"      -- let the cursor go anywhere in visual block
opt.gdefault = false
opt.shortmess:append("c")      -- don't show completion menu messages
opt.iskeyword:append("-")      -- treat foo-bar as one word for w/e/b

-- == Folding (treesitter-powered, but open by default) ====================
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- == Grep uses ripgrep ===================================================
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case --hidden"
  opt.grepformat = "%f:%l:%c:%m"
end

-- == Diagnostics appearance ==============================================
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.HINT] = "⚑",
      [vim.diagnostic.severity.INFO] = "»",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = true },
})
