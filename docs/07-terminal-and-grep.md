# 07 — Terminal & project-wide grep

[← Back to index](README.md) · Prev: [Multi-cursor & macros](06-multicursor-and-macros.md) · Next: [Git →](08-git.md)

Two closely-related superpowers: a real terminal living inside the editor (that
you can scroll and search like a file, Emacs-style), and a project-wide search
that gets you from "where is this string?" to "editing that exact line" in about
four keystrokes.

## The integrated terminal

| Keys | Action |
|------|--------|
| `<C-\>` | toggle a floating terminal (open/close) |
| `<leader>tf` | terminal as a **float** |
| `<leader>th` | terminal in a **horizontal** split |
| `<leader>tv` | terminal in a **vertical** split |
| `<leader>tg` | a dedicated **lazygit** terminal |

The terminal opens in your project directory, so commands like `ls`, `make`,
`pytest`, `cargo run`, or `grep` run from the right place.

### Typing vs. scrolling: terminal modes

A terminal buffer has two modes, just like the editor:

- **Terminal (insert) mode** — you're typing into the shell. This is the default
  when the terminal opens.
- **Terminal-normal mode** — the terminal output behaves like a read-only file
  you can navigate.

| Keys | Action |
|------|--------|
| `<Esc><Esc>` | switch from typing → **terminal-normal mode** |
| `i` or `a` | switch back to typing |
| `<C-h/j/k/l>` | jump straight to another window from the terminal |

### Scrolling and searching output (the Emacs-like part)

Once you're in **terminal-normal mode** (`<Esc><Esc>`), the entire scrollback is
just a buffer. Every normal-mode motion works:

| Keys | Action |
|------|--------|
| `j` / `k`, `<C-u>` / `<C-d>` | scroll line / half-page |
| `gg` / `G` | jump to the top / bottom of the output |
| `/text` then `<CR>`, `n`/`N` | **search** the output, jump between hits |
| `v` … `y` | visually select and yank output text |
| `*` | search for the word under the cursor |

So you can run a long build, hit `<Esc><Esc>`, then `/error` `<CR>` to jump
straight to the first error in the scrollback — no mouse, no scrollbar.

## Project-wide grep → open the file at the line

This is the headline workflow. Two flavors:

### A) Telescope live grep (interactive, recommended)

| Keys | Action |
|------|--------|
| `<leader>fg` | live grep across the whole project |
| `<leader>fw` | grep the word under the cursor |
| `<leader>fw` (visual) | grep the current selection |

It searches from your project root using ripgrep, updating results as you type.

**From query to editing the line in ~4 keystrokes:**

1. `<leader>fg` — open live grep.
2. type part of the string, e.g. `TODO` — results stream in with a live preview.
3. `<C-j>` / `<C-k>` — move to the result you want.
4. `<CR>` — opens that file with the cursor on that exact line.

That's it. Want it in a split instead? Use `<C-v>` (vertical) or `<C-s>`
(horizontal) on step 4. Want all matches in a list to work through? Press `<C-q>`
to dump them into the quickfix list, then walk it with `]q` / `[q`.

### B) Raw `grep`/`rg` in the terminal

If you prefer the literal command:

1. `<C-\>` to open the terminal.
2. Run your search from the current directory, e.g.:

```bash
grep -rn "some text" .
# or, faster and respecting .gitignore:
rg -n "some text"
```

3. `<Esc><Esc>` to enter terminal-normal mode.
4. `/some text` `<CR>` to jump between hits, or `gf` with the cursor on a
   `path:line` to **go to that file**.

> Tip: `:grep "some text"` (no terminal needed) runs ripgrep and fills the
> quickfix list directly — then `<leader>co` to open it and `]q` / `[q` to step
> through, `<CR>` to jump to a match.

## Quickfix list — batch-process search hits

The quickfix list is a worklist of locations. It pairs perfectly with grep.

| Keys / cmd | Action |
|------------|--------|
| `<C-q>` (in Telescope) | send results to quickfix |
| `<leader>co` / `<leader>cc` | open / close the quickfix list |
| `]q` / `[q` | next / previous item (jumps to the file+line) |
| `<leader>xq` | open quickfix in [Trouble](09-keybindings-reference.md) (nicer UI) |
| `:cdo s/old/new/g \| update` | run a substitution on **every** quickfix entry |

That last one is how you do a project-wide find-and-replace: grep → `<C-q>` →
`:cdo s/old/new/g | update`.

Practice with [Drills 11–14](10-practice-drills.md).
