# 02 — Cheat sheet (the fridge magnet)

[← Back to index](README.md) · Prev: [Getting started](01-getting-started.md) · Next: [Motions & editing →](03-motions-and-editing.md)

The whole setup on one page. `<leader>` = **Space**. For the exhaustive list see
the [keybindings reference](09-keybindings-reference.md).

## Survival

| Keys | Action |
|------|--------|
| `<Esc>` | Back to normal mode / clear search highlight |
| `i` `a` `o` | Insert before / after / new line below |
| `u` / `<C-r>` | Undo / redo |
| `<leader>w` / `<leader>q` | Save / quit |
| `:` | Command line |
| `<Space>` (wait) | Show all shortcuts (which-key) |

## Move

| Keys | Action |
|------|--------|
| `h j k l` | Left / down / up / right |
| `w` `b` `e` | Next word / back / end of word |
| `0` `^` `$` | Start of line / first non-blank / end |
| `gg` `G` | Top / bottom of file |
| `10j` `8k` | Down 10 / up 8 (use the relative numbers) |
| `{` `}` | Previous / next paragraph |
| `%` | Jump to matching bracket |
| `f<x>` `t<x>` | Jump to / before next `x` on the line (`;`/`,` repeat) |
| `*` `#` | Next / previous occurrence of word under cursor |
| `s` | **Flash**: jump anywhere on screen by label |
| `<C-d>` `<C-u>` | Half page down / up (centered) |

## Edit (operator + motion)

| Keys | Action |
|------|--------|
| `dw` `d$` `dd` | Delete word / to end of line / whole line |
| `cw` `cc` | Change word / whole line |
| `yy` `yiw` | Yank line / inner word |
| `p` `P` | Paste after / before |
| `>>` `<<` | Indent / dedent line |
| `.` | Repeat last change |
| `ciw` `ci"` `ci(` | Change inner word / quotes / parens |
| `dap` `yi{` | Delete a paragraph / yank inside braces |
| `ysiw"` | Surround word with `"` |
| `cs"'` / `ds"` | Change `"`→`'` / delete surrounding `"` |
| `gcc` / `gc` (visual) | Toggle comment |
| `cxiw` … `cxiw` | Swap two words (vim-exchange) |
| `<leader>sw` | Swap current word with the next |

## Find & open

| Keys | Action |
|------|--------|
| `<leader>ff` | Find files (fuzzy) |
| `<leader>fr` | Recent files |
| `<leader>fb` / `<leader><space>` | Switch buffers |
| `<leader>fg` | **Live grep** the whole project |
| `<leader>fw` | Grep the word under cursor |
| `<leader>/` | Search within current file |
| `<leader>e` | Toggle file explorer |
| `<leader>fT` | Find all TODO/FIXME |

Inside any picker: `<C-j>/<C-k>` move · `<CR>` open · `<C-v>/<C-s>` open in
split · `<C-q>` send all results to quickfix.

## Code (LSP)

| Keys | Action |
|------|--------|
| `gd` | Go to definition |
| `gr` | References |
| `gi` | Implementation |
| `K` | Hover documentation |
| `<C-o>` / `<A-Left>` | Jump **back** |
| `<C-i>` / `<A-Right>` | Jump **forward** |
| `<leader>rn` | Rename symbol everywhere |
| `<leader>ca` | Code action / quick fix |
| `<leader>cf` | Format buffer (also auto on save) |
| `[d` `]d` | Previous / next diagnostic |
| `<leader>xx` | Diagnostics list (Trouble) |
| `<C-Space>` | Trigger completion (in insert) |
| `<Tab>` / `<CR>` | Accept completion |

## Multiple cursors

| Keys | Action |
|------|--------|
| `<C-n>` | Select word, press again to add next match |
| `<C-Down>` / `<C-Up>` | Add cursor below / above |
| `<C-x>` | Skip this match |
| `n` / `N` | Next / previous occurrence (in multi mode) |
| `c` / `i` / `a` | Then edit all cursors at once |

## Windows, buffers, terminal

| Keys | Action |
|------|--------|
| `<leader>sv` / `<leader>sh` | Split vertical / horizontal |
| `<C-h/j/k/l>` | Move between splits |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<leader>bd` | Close buffer |
| `<C-\>` | Toggle integrated terminal |
| `<Esc><Esc>` (in terminal) | Terminal normal mode (scroll/search) |

## Git

| Keys | Action |
|------|--------|
| `<leader>gg` | Open lazygit |
| `]h` / `[h` | Next / previous changed hunk |
| `<leader>hs` / `<leader>hr` | Stage / reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |

---

Tip: open this file in a vertical split next to your work with
`<leader>sv` then `<leader>ff` and type `cheatsheet`.
