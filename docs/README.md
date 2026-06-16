# nvim-dev docs — learn it, then own it

These docs are two things at once:

1. A **cheat sheet** you keep open in a split while you work.
2. A **practice course** that takes you from "I just installed this" to "I never
   touch the mouse" in about a week.

> Leader key is **Space** (`<leader>` below). Whenever you forget a shortcut,
> press `<Space>` and wait — [which-key](09-keybindings-reference.md) pops up
> with every option. You genuinely don't have to memorize anything cold.

## Recommended learning path

### Day 1 — survive and move
- [01 — Getting started](01-getting-started.md): modes, the leader key, hybrid
  line numbers, saving/quitting, asking the editor for help.
- [02 — Cheat sheet](02-cheatsheet.md): skim it, keep it open.
- Do **Drills 1–4** in [10 — Practice drills](10-practice-drills.md).

### Days 2–3 — edit at the speed of thought
- [03 — Motions & editing](03-motions-and-editing.md): the grammar of Vim
  (operator + motion), text objects, dot-repeat, surround, word swapping.
- Do **Drills 5–9**.

### Days 4–5 — navigate any codebase
- [04 — Navigation & search](04-navigation-and-search.md): flash jumps, fuzzy
  find, the jumplist (go-to-definition back/forward), file explorer.
- [07 — Terminal & grep](07-terminal-and-grep.md): the integrated terminal and
  the "grep the project, open the file at the line in ~4 keystrokes" workflow.
- Do **Drills 10–14**.

### Days 6–7 — code like an IDE
- [05 — LSP & coding](05-lsp-and-coding.md): autocomplete, go-to-definition,
  rename, code actions, diagnostics, format on save.
- [06 — Multi-cursor & macros](06-multicursor-and-macros.md): VS Code-style
  multi-cursors and classic Vim macros.
- [08 — Git](08-git.md): stage hunks, blame, lazygit.
- Do **Drills 15–20**.

### Whenever something breaks
- [11 — Troubleshooting](11-troubleshooting.md).
- [12 — Dependencies](12-dependencies.md) — full package, Mason, and plugin list.

## All pages

| # | Page | What it covers |
|---|------|----------------|
| 01 | [Getting started](01-getting-started.md) | Modes, leader, line numbers, help |
| 02 | [Cheat sheet](02-cheatsheet.md) | The one-page summary |
| 03 | [Motions & editing](03-motions-and-editing.md) | Operators, motions, text objects |
| 04 | [Navigation & search](04-navigation-and-search.md) | Jumps, fuzzy find, jumplist |
| 05 | [LSP & coding](05-lsp-and-coding.md) | Autocomplete, gd, rename, diagnostics |
| 06 | [Multi-cursor & macros](06-multicursor-and-macros.md) | Multi-cursors, macros |
| 07 | [Terminal & grep](07-terminal-and-grep.md) | Integrated terminal, project search |
| 08 | [Git](08-git.md) | Hunks, blame, lazygit |
| 09 | [Keybindings reference](09-keybindings-reference.md) | Every custom mapping |
| 10 | [Practice drills](10-practice-drills.md) | 20 graded exercises |
| 11 | [Troubleshooting](11-troubleshooting.md) | When things go wrong |
| 12 | [Dependencies](12-dependencies.md) | Full deploy: apt, Mason, plugins |

## Practice files

The drills use the deliberately-messy sample files in
[`practice/`](practice/):

- [`practice.py`](practice/practice.py) — Python
- [`practice.cpp`](practice/practice.cpp) — C++
- [`refactor-me.js`](practice/refactor-me.js) — JavaScript

Open them with `<leader>ff` and follow along.

## The golden rule

Don't try to learn everything at once. Pick **three** new keys each day, force
yourself to use them, and let the rest stay on the cheat sheet until you need
them. Speed is a side effect of repetition, not memorization.
