-- keymaps.lua — global, non-plugin keymaps.
-- Plugin-specific maps live with their plugin spec; LSP maps attach per-buffer
-- in plugins/lsp.lua. The keybindings reference doc mirrors this file.

local map = vim.keymap.set

local function opts(desc)
  return { noremap = true, silent = true, desc = desc }
end

-- == Basics ===============================================================
-- Clear search highlight with <Esc>.
map("n", "<Esc>", "<cmd>nohlsearch<cr>", opts("Clear search highlight"))

-- Save / quit.
map("n", "<leader>w", "<cmd>write<cr>", opts("Save file"))
map("n", "<leader>q", "<cmd>quit<cr>", opts("Quit window"))
map("n", "<leader>Q", "<cmd>qa<cr>", opts("Quit all"))

-- == Jumplist: go to definition "back/forward" like VS Code ==============
-- Ctrl-o / Ctrl-i are the native jumplist. We also bind Alt-Left / Alt-Right
-- so it feels exactly like VS Code's navigate back/forward.
map("n", "<A-Left>", "<C-o>", opts("Jump back (jumplist)"))
map("n", "<A-Right>", "<C-i>", opts("Jump forward (jumplist)"))
-- Some terminals send these escape sequences for Alt+Arrow; cover them too.
map("n", "<M-Left>", "<C-o>", opts("Jump back (jumplist)"))
map("n", "<M-Right>", "<C-i>", opts("Jump forward (jumplist)"))

-- == Window navigation (no mouse) ========================================
map("n", "<C-h>", "<C-w>h", opts("Go to left window"))
map("n", "<C-j>", "<C-w>j", opts("Go to lower window"))
map("n", "<C-k>", "<C-w>k", opts("Go to upper window"))
map("n", "<C-l>", "<C-w>l", opts("Go to right window"))

-- Resize windows with arrows.
map("n", "<C-Up>", "<cmd>resize +2<cr>", opts("Increase window height"))
map("n", "<C-Down>", "<cmd>resize -2<cr>", opts("Decrease window height"))
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", opts("Decrease window width"))
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", opts("Increase window width"))

-- Splits.
map("n", "<leader>sv", "<cmd>vsplit<cr>", opts("Split window vertically"))
map("n", "<leader>sh", "<cmd>split<cr>", opts("Split window horizontally"))
map("n", "<leader>sx", "<cmd>close<cr>", opts("Close current split"))

-- == Buffers / tabs ======================================================
map("n", "<Tab>", "<cmd>bnext<cr>", opts("Next buffer"))
map("n", "<S-Tab>", "<cmd>bprevious<cr>", opts("Previous buffer"))
map("n", "<leader>bd", "<cmd>bdelete<cr>", opts("Delete buffer"))
map("n", "<leader>bb", "<cmd>e #<cr>", opts("Switch to other buffer"))

-- == Up/down: always land at first non-blank of the line (^) ==============
-- Standard "browse code" maps: j/k move by line, not by column.
-- opt.wrap is off in options.lua, so plain j^/k^ is enough (no gj needed).
map("n", "j", "j^", opts("Down (start of line)"))
map("n", "k", "k^", opts("Up (start of line)"))
map({ "x", "o" }, "j", "j", opts("Down"))
map({ "x", "o" }, "k", "k", opts("Up"))

-- == Block / scope navigation (pairs with % for brackets) ================
-- %     jump between matching (), [], {}
-- g%    end of current block/scope (]M) — "where this block closes"
-- [b    start of current block/scope ([m)
-- Also (treesitter, in code files): [f ]f function  |  [c ]c class
map("n", "g%", "]M", opts("End of current block"))
map("n", "[b", "[m", opts("Start of current block"))
map("n", "]b", "]M", opts("End of current block"))

-- == Half-page scroll (centered) =========================================
-- Ctrl-d = multi-cursor (VS Code) in editor.lua — do not use for scrolling.
map("n", "<C-f>", "<C-d>zz", opts("Half page down (centered)"))
map("n", "<C-u>", "<C-u>zz", opts("Half page up (centered)"))
map("n", "n", "nzzzv", opts("Next search result (centered)"))
map("n", "N", "Nzzzv", opts("Prev search result (centered)"))

-- == Move selected lines up/down in visual mode ==========================
map("v", "J", ":m '>+1<cr>gv=gv", opts("Move selection down"))
map("v", "K", ":m '<-2<cr>gv=gv", opts("Move selection up"))

-- == Stay in indent mode when shifting in visual ==========================
map("v", "<", "<gv", opts("Indent left and reselect"))
map("v", ">", ">gv", opts("Indent right and reselect"))

-- == Paste over selection without clobbering the yank register ============
map("x", "<leader>p", [["_dP]], opts("Paste without yanking selection"))

-- == Delete to black hole (don't overwrite the yank) ======================
map({ "n", "v" }, "<leader>d", [["_d]], opts("Delete without yanking"))

-- == Swap the current word with the next word (quick "switch two words") ==
-- Uses a small expression: yank inner word, find next word, paste/swap.
-- For true two-spot exchange see vim-exchange (cx / cxiw) in plugins/editor.lua.
map("n", "<leader>sw", function()
  -- :s swap adjacent words separated by punctuation/space, keeping cursor.
  local save = vim.fn.winsaveview()
  vim.cmd([[silent! s/\v(<\k+>)(\s+)(<\k+>)/\3\2\1/]])
  vim.fn.winrestview(save)
  vim.cmd("nohlsearch")
end, opts("Swap current word with the next"))

-- == Quickfix navigation (used by grep -> quickfix workflow) =============
map("n", "<leader>co", "<cmd>copen<cr>", opts("Open quickfix list"))
map("n", "<leader>cc", "<cmd>cclose<cr>", opts("Close quickfix list"))
map("n", "]q", "<cmd>cnext<cr>zz", opts("Next quickfix item"))
map("n", "[q", "<cmd>cprev<cr>zz", opts("Previous quickfix item"))

-- == Terminal mode escape hatch ==========================================
-- Press <Esc><Esc> in the integrated terminal to drop into normal mode so you
-- can scroll/search the output with j/k and /.
map("t", "<Esc><Esc>", [[<C-\><C-n>]], opts("Terminal: go to normal mode"))
