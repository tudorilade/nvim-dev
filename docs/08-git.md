# 08 — Git

[← Back to index](README.md) · Prev: [Terminal & grep](07-terminal-and-grep.md) · Next: [Keybindings reference →](09-keybindings-reference.md)

Two layers of git integration: **gitsigns** for inline, line-level work (see and
stage individual changes right in the buffer) and **lazygit** for everything
bigger (commits, branches, rebases, history) in a full terminal UI.

## Inline changes with gitsigns

As you edit a tracked file, the sign column on the left shows what changed:

- `▎` added or changed lines
- a marker where lines were deleted

### Navigating and staging hunks

A "hunk" is a contiguous block of changes.

| Keys | Action |
|------|--------|
| `]h` / `[h` | jump to the next / previous hunk |
| `<leader>hp` | **preview** the hunk under the cursor (see the diff inline) |
| `<leader>hs` | **stage** the hunk |
| `<leader>hr` | **reset** the hunk (discard the change) |
| `<leader>hs` (visual) | stage just the selected lines |
| `<leader>hr` (visual) | reset just the selected lines |
| `<leader>hS` | stage the whole buffer |
| `<leader>hR` | reset the whole buffer |
| `<leader>hd` | diff the file against the index |

### Blame

| Keys | Action |
|------|--------|
| `<leader>hb` | full blame for the current line (who, when, which commit) |
| `<leader>hB` | toggle live inline blame for every line |

This is great for "why is this line here?" — `<leader>hb` shows the commit
message and author without leaving the file.

## Bigger operations with lazygit

For staging across files, writing commit messages, branching, stashing, viewing
log/graph, interactive rebase, resolving conflicts — use lazygit.

| Keys | Action |
|------|--------|
| `<leader>gg` | open lazygit (whole repo) |
| `<leader>gf` | open lazygit focused on the current file |
| `<leader>tg` | lazygit in a toggle terminal |

### lazygit quick keys (inside the lazygit UI)

| Keys | Action |
|------|--------|
| `<Tab>` | move between panels (files, branches, commits, stash) |
| `<Space>` | stage / unstage the selected file or hunk |
| `a` | stage / unstage **all** |
| `c` | commit (opens a message editor) |
| `C` | commit using your `$EDITOR` (nvim) |
| `P` / `p` | push / pull |
| `b` | branch menu · `n` new branch |
| `d` | view diff / discard |
| `z` / `Z` | undo / redo (reflog-based) |
| `?` | help (every key, in context) |
| `q` | quit back to the editor |

> lazygit has its own excellent built-in help — press `?` any time. You rarely
> need to memorize it.

## Finding things in history

| Keys | Action |
|------|--------|
| `<leader>fg` then refine | grep the working tree (see [grep](07-terminal-and-grep.md)) |
| `:LazyGitFilter` | browse commit history / search log (via lazygit) |
| `<leader>hb` | blame to find the commit that touched a line |

## A typical flow

1. Edit code. Watch the gutter mark your changes.
2. `<leader>hp` to review a change, `<leader>hs` to stage it (or skip to lazygit).
3. `<leader>gg` to open lazygit.
4. `a` to stage everything (or `<Space>` per file), `c` to write a commit.
5. `P` to push. `q` to return to editing.
