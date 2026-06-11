# 04 — Navigation & search

[← Back to index](README.md) · Prev: [Motions & editing](03-motions-and-editing.md) · Next: [LSP & coding →](05-lsp-and-coding.md)

How to move around a single file, across files, and around an entire codebase —
all without a mouse.

## Within the current file

| Keys | Action |
|------|--------|
| `s` + 2 chars | **Flash**: type any 2 characters on screen, then a label, to teleport the cursor there |
| `/text` then `<CR>` | search forward; `n`/`N` to repeat |
| `?text` | search backward |
| `*` / `#` | search the word under the cursor forward / back |
| `<leader>/` | fuzzy-search lines in this buffer (Telescope) |
| `%` | jump to the matching bracket |
| `<C-d>` / `<C-u>` | half-page down / up (kept centered) |
| `H` `M` `L` | top / middle / bottom of the visible screen |

**Flash** is the fastest way to move on screen. Press `s`, then start typing the
text you want to land on; matches get one-letter labels — press the label and
you're there. It works as a motion too: `ds<label>` deletes up to a flash
target.

## Across files (fuzzy finding)

Telescope is your command center. All of these open a fuzzy picker:

| Keys | Opens |
|------|-------|
| `<leader>ff` | files in the project |
| `<leader>fa` | files including hidden / git-ignored |
| `<leader>fr` | recently opened files |
| `<leader>fb` or `<leader><space>` | open buffers |
| `<leader>fg` | live grep across the project (see [Terminal & grep](07-terminal-and-grep.md)) |
| `<leader>fw` | grep the word under the cursor |
| `<leader>fh` | help pages |
| `<leader>fk` | all keymaps |
| `<leader>fc` | all commands |
| `<leader>fs` | symbols in the current file |
| `<leader>fR` | resume the last picker where you left off |

### Inside a picker

| Keys | Action |
|------|--------|
| type | fuzzy-filter the list |
| `<C-j>` / `<C-k>` | move selection down / up |
| `<CR>` | open the selection |
| `<C-v>` / `<C-s>` | open in a vertical / horizontal split |
| `<C-t>` | open in a new tab |
| `<C-q>` | send **all** results to the quickfix list |
| `<C-u>` / `<C-d>` | scroll the preview |
| `<Esc>` | close the picker |

## The jumplist — go-to-definition "back" and "forward"

This is the VS Code Alt-Left / Alt-Right experience. Vim records your big jumps
(searches, `gd`, `G`, `{`/`}`, etc.) in a **jumplist** you can walk:

| Keys | Action |
|------|--------|
| `gd` | go to definition (may open another file) |
| `<C-o>` or `<A-Left>` | jump **back** to where you were |
| `<C-i>` or `<A-Right>` | jump **forward** again |
| `:jumps` | view the whole jumplist |
| `` `` `` (backtick backtick) | toggle between the last two positions |

So the classic flow is: `gd` to dive into a function, read it, then `<C-o>` (or
`<A-Left>`) to pop right back to the call site — across files, as deep as you
like.

The **changelist** is similar but for edits: `g;` / `g,` jump to where you last
changed text.

## Windows (splits)

| Keys | Action |
|------|--------|
| `<leader>sv` | split vertically |
| `<leader>sh` | split horizontally |
| `<C-h/j/k/l>` | move to the left/down/up/right window |
| `<C-Left/Right/Up/Down>` | resize the current window |
| `<leader>sx` | close the current split |
| `<C-w>o` | close every other window |
| `<C-w>=` | equalize window sizes |

## Buffers and tabs

Open files are **buffers**; the bar across the top shows them like tabs.

| Keys | Action |
|------|--------|
| `<Tab>` / `<S-Tab>` | next / previous buffer |
| `<leader>1`…`<leader>4` | jump to buffer 1–4 |
| `<leader>bp` | pick a buffer by label |
| `<leader>bd` | close the current buffer |
| `<leader>bb` | toggle to the previously edited buffer |

## File explorer

| Keys | Action |
|------|--------|
| `<leader>e` | toggle the tree |
| `<leader>o` | reveal the current file in the tree |

Inside the tree (no mouse needed):

| Keys | Action |
|------|--------|
| `<CR>` / `o` | open file / expand folder |
| `a` | create a file (end with `/` to make a folder) |
| `d` | delete · `r` rename · `x` cut · `c` copy · `p` paste |
| `<C-v>` / `<C-x>` | open in vertical / horizontal split |
| `R` | refresh · `H` toggle hidden files |
| `q` | close the tree |

Practice with [Drills 10–14](10-practice-drills.md).
