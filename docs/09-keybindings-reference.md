# 09 — Keybindings reference

[← Back to index](README.md) · Prev: [Git](08-git.md) · Next: [Practice drills →](10-practice-drills.md)

Every custom mapping in this config, grouped. `<leader>` = **Space**,
`<localleader>` = **,** (comma). This mirrors
[`nvim/lua/config/keymaps.lua`](../nvim/lua/config/keymaps.lua) and the plugin
specs in [`nvim/lua/plugins/`](../nvim/lua/plugins/).

> Forgot one? Press `<Space>` and wait for which-key, or run `<leader>fk` to
> fuzzy-search all keymaps live.

## Files, search, pickers (Telescope)

| Keys | Mode | Action |
|------|------|--------|
| `<leader>ff` | n | Find files |
| `<leader>fa` | n | Find all files (incl. hidden / ignored) |
| `<leader>fr` | n | Recent files |
| `<leader>fb` | n | Buffers |
| `<leader><space>` | n | Buffers |
| `<leader>fg` | n | Live grep (project) |
| `<leader>fw` | n / v | Grep word under cursor / selection |
| `<leader>/` | n | Fuzzy search in current buffer |
| `<leader>fh` | n | Help tags |
| `<leader>fk` | n | Keymaps |
| `<leader>fc` | n | Commands |
| `<leader>fd` | n | Diagnostics (workspace) |
| `<leader>ft` | n | Theme/colorscheme picker |
| `<leader>fR` | n | Resume last picker |
| `<leader>fT` | n | Find TODO/FIXME comments |
| `<leader>fs` | n | Document symbols (LSP) |
| `<leader>fS` | n | Workspace symbols (LSP) |

### Inside a picker

| Keys | Action |
|------|--------|
| `<C-j>` / `<C-k>` | Move selection down / up |
| `<C-n>` / `<C-p>` | Move selection down / up |
| `<CR>` | Open selection |
| `<C-v>` / `<C-s>` | Open in vertical / horizontal split |
| `<C-t>` | Open in new tab |
| `<C-q>` | Send all results to quickfix |
| `<M-q>` | Send selected to quickfix |
| `<C-u>` / `<C-d>` | Scroll preview up / down |
| `<C-d>` (buffers) | Delete the buffer |
| `<Esc>` | Close picker |

## Motion & on-screen jumps

| Keys | Mode | Action |
|------|------|--------|
| `s` | n/x/o | Flash jump to any on-screen target |
| `S` | n/x/o | Flash treesitter (select node) |
| `r` | o | Remote flash (operate at a distance) |
| `R` | o/x | Flash treesitter search |
| `j` / `k` | n/x | Down/up (display lines when no count) |
| `<C-d>` / `<C-u>` | n | Half-page down / up (centered) |
| `n` / `N` | n | Next / prev search result (centered) |
| `<C-space>` | n | Treesitter incremental selection (expand) |
| `<bs>` | n | Treesitter selection (shrink) |

## Windows & buffers

| Keys | Action |
|------|--------|
| `<C-h/j/k/l>` | Move to left/down/up/right window |
| `<C-Up>/<C-Down>` | Increase / decrease window height |
| `<C-Left>/<C-Right>` | Decrease / increase window width |
| `<leader>sv` / `<leader>sh` | Split vertical / horizontal |
| `<leader>sx` | Close current split |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<leader>bd` | Delete buffer |
| `<leader>bb` | Toggle to last buffer |
| `<leader>bp` | Pick buffer by label (bufferline) |
| `<leader>1`…`<leader>4` | Go to buffer 1–4 |

## Editing

| Keys | Mode | Action |
|------|------|--------|
| `<Esc>` | n | Clear search highlight |
| `J` / `K` | v | Move selection down / up |
| `<` / `>` | v | Dedent / indent and keep selection |
| `<leader>p` | x | Paste over selection without yanking it |
| `<leader>d` | n/v | Delete to black hole (don't touch clipboard) |
| `<leader>sw` | n | Swap current word with the next |
| `cx` + motion | n | Exchange (mark, then exchange) |
| `cxx` | n | Exchange line |
| `cxc` | n | Cancel pending exchange |
| `X` | x | Exchange visual selection |
| `ysiw)` etc. | n | Surround (add) |
| `cs"'` | n | Surround (change) |
| `ds"` | n | Surround (delete) |
| `S<x>` | x | Surround the selection |
| `gcc` / `gc` | n / v | Toggle comment |

## Treesitter text objects

| Keys | Selects |
|------|---------|
| `af` / `if` | a / inner function |
| `ac` / `ic` | a / inner class |
| `aa` / `ia` | a / inner parameter |
| `al` / `il` | a / inner loop |
| `ai` / `ii` | a / inner conditional |
| `]f` / `[f` | next / prev function start |
| `]c` / `[c` | next / prev class start |
| `]a` / `[a` | next / prev parameter |
| `<leader>na` / `<leader>pa` | swap parameter with next / prev |

(Plus mini.ai objects: `ao`/`io` blocks, and the standard `iw aw i" i( ip it`.)

## Multiple cursors (vim-visual-multi)

| Keys | Action |
|------|--------|
| `<C-n>` | Select word / add cursor at next match |
| `<C-Down>` / `<C-Up>` | Add cursor below / above |
| `<C-x>` | Skip current match |
| `<C-p>` | Remove last cursor |
| `<leader>A` | Select all occurrences |
| `n` / `N` | Next / prev occurrence (in VM mode) |

## LSP (active when a server is attached)

| Keys | Mode | Action |
|------|------|--------|
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gr` | n | References |
| `gi` | n | Go to implementation |
| `gy` | n | Type definition |
| `K` | n | Hover documentation |
| `gK` | n | Signature help |
| `<C-k>` | i | Signature help |
| `<leader>rn` | n | Rename symbol |
| `<leader>ca` | n/x | Code action |
| `<leader>cf` | n/v | Format buffer |
| `<leader>cd` | n | Line diagnostics (float) |
| `[d` / `]d` | n | Prev / next diagnostic |
| `<leader>th` | n | Toggle inlay hints |

## Jumplist (go-to-definition back/forward)

| Keys | Action |
|------|--------|
| `<C-o>` / `<A-Left>` / `<M-Left>` | Jump back |
| `<C-i>` / `<A-Right>` / `<M-Right>` | Jump forward |

## Diagnostics / Trouble

| Keys | Action |
|------|--------|
| `<leader>xx` | Diagnostics list (Trouble) |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xs` | Symbols panel |
| `<leader>xq` | Quickfix in Trouble |
| `<leader>xl` | Location list in Trouble |
| `]t` / `[t` | Next / prev TODO comment |

## Quickfix

| Keys | Action |
|------|--------|
| `<leader>co` / `<leader>cc` | Open / close quickfix |
| `]q` / `[q` | Next / previous quickfix item |

## Terminal

| Keys | Mode | Action |
|------|------|--------|
| `<C-\>` | n/t | Toggle terminal |
| `<leader>tf` | n | Terminal (float) |
| `<leader>th` | n | Terminal (horizontal) |
| `<leader>tv` | n | Terminal (vertical) |
| `<leader>tg` | n | Lazygit terminal |
| `<Esc><Esc>` | t | Enter terminal-normal mode (scroll/search) |
| `<C-h/j/k/l>` | t | Move to another window |

## Git

| Keys | Mode | Action |
|------|------|--------|
| `<leader>gg` | n | Lazygit |
| `<leader>gf` | n | Lazygit (current file) |
| `]h` / `[h` | n | Next / prev hunk |
| `<leader>hs` / `<leader>hr` | n/v | Stage / reset hunk (or selection) |
| `<leader>hS` / `<leader>hR` | n | Stage / reset buffer |
| `<leader>hp` | n | Preview hunk |
| `<leader>hb` / `<leader>hB` | n | Blame line / toggle inline blame |
| `<leader>hd` | n | Diff this file |

## Explorer (nvim-tree)

| Keys | Action |
|------|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>o` | Reveal current file in explorer |
| `<CR>`/`o`, `a`, `d`, `r`, `x`, `c`, `p`, `R`, `H`, `q` | open, add, delete, rename, cut, copy, paste, refresh, toggle hidden, close (inside the tree) |

## Sessions

| Keys | Action |
|------|--------|
| `<leader>qs` | Restore session for this directory |
| `<leader>ql` | Restore the last session |
| `<leader>qd` | Stop saving the session |

## Misc

| Keys | Action |
|------|--------|
| `<leader>w` / `<leader>q` / `<leader>Q` | Save / quit / quit all |
| `<leader>L` | Open Lazy (plugin manager) |
| `<leader>?` | Show buffer-local keymaps (which-key) |
| `q` | Close help/quickfix/man/etc. popups |
