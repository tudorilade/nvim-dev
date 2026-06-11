# 10 — Practice drills

[← Back to index](README.md) · Prev: [Keybindings reference](09-keybindings-reference.md) · Next: [Troubleshooting →](11-troubleshooting.md)

Twenty graded exercises that build real muscle memory. Each says **what to do**,
**the keys**, and **the goal**. Do them in order; redo any that felt slow.

Open the practice files first (they live in
[`docs/practice/`](practice/)):

```
<leader>ff   then type:  practice.py
<leader>ff   then type:  practice.cpp
<leader>ff   then type:  refactor-me.js
```

> Reset a practice file any time with `git checkout docs/practice/` (or just
> undo with `u`).

---

## Tier 1 — Movement & survival (Day 1)

### Drill 1 — Move without arrows
**File:** any. **Goal:** never touch the arrow keys.
- Use `h j k l` to move around for two minutes.
- Jump by words: `w` (forward), `b` (back), `e` (end of word).
- Line ends: `0` (start), `^` (first non-blank), `$` (end).

### Drill 2 — Count-based jumps (hybrid numbers)
**File:** `practice.py`. **Goal:** read the relative number and jump exactly.
- Pick a line ~10 away and reach it in one motion: `10j` or `8k`.
- `gg` to the top, `G` to the bottom, `:20<CR>` to line 20.

### Drill 3 — Insert, undo, save
**File:** `practice.py`. **Goal:** the edit/undo/save loop.
- `o` to open a new line, type a comment, `<Esc>`.
- `u` to undo, `<C-r>` to redo.
- `<leader>w` to save.

### Drill 4 — Find on a line
**File:** `practice.py`. **Goal:** `f`/`t` precision.
- On a `print(...)` line, `f(` to jump to the paren, `;` for the next, `,` back.
- `ci(` to change everything inside the parentheses.

---

## Tier 2 — Editing grammar (Days 2–3)

### Drill 5 — Delete a paragraph
**File:** `refactor-me.js`. **Goal:** text objects over counting.
- Put the cursor on the `TEMP_DEBUG` block.
- `dap` deletes the whole paragraph at once. Undo with `u`.

### Drill 6 — Change surrounding quotes
**File:** `refactor-me.js`. **Goal:** nvim-surround.
- Cursor on the `greeting` string. `cs'"` turns `'…'` into `"…"`.
- `ds"` removes the quotes; `ysiw"` puts them back around the word.

### Drill 7 — Operate inside brackets
**File:** `refactor-me.js`. **Goal:** `i`/`a` objects.
- Cursor anywhere inside the `colors` array.
- `yi[` to yank inside the brackets, `ci[` to change it, `di[` to delete it.

### Drill 8 — Exchange two arguments
**File:** `refactor-me.js`, `makePair(first, second)`. **Goal:** vim-exchange.
- Cursor on `first` → `cxiw`.
- Cursor on `second` → `cxiw`. They swap.
- Bonus: `<leader>sw` swaps the current word with the next in one shot.

### Drill 9 — Dot-repeat
**File:** `practice.py`. **Goal:** make `.` do the work.
- On a line, `A;` `<Esc>` to append a semicolon.
- `j` then `.` to repeat down several lines.

---

## Tier 3 — Navigation & search (Days 4–5)

### Drill 10 — Flash jump
**File:** `practice.cpp`. **Goal:** move anywhere in 3 keys.
- Press `s`, then type 2 characters of a word across the screen, then the label.

### Drill 11 — Fuzzy find files
**Goal:** open files by name, not by clicking.
- `<leader>ff`, type `cpp`, `<CR>` to open `practice.cpp`.
- `<leader>fr` to hop back to a recent file.

### Drill 12 — Live grep, open at the line
**Goal:** the ~4-keystroke search-to-edit flow.
- `<leader>fg`, type `TODO`.
- `<C-j>` to the result you want, `<CR>` to open exactly there.
- Repeat with `<leader>fw` while the cursor is on a function name.

### Drill 13 — Grep to quickfix and walk it
**Goal:** batch navigation.
- `<leader>fg`, type `print`, then `<C-q>` to send all hits to quickfix.
- `]q` / `[q` to step through every match; `<leader>co` to see the list.

### Drill 14 — Splits and the jumplist
**File:** `practice.py`. **Goal:** windows + back/forward.
- `<leader>sv` to split, `<C-h>`/`<C-l>` to move between them.
- `gd` on `calc`, then `<C-o>` (or `<A-Left>`) to jump back.

---

## Tier 4 — IDE features (Days 6–7)

### Drill 15 — Go to definition and back
**File:** `practice.py`. **Goal:** cross-symbol navigation.
- Cursor on `calc` inside `calc_volume`. Press `gd` to jump to its definition.
- `<C-o>` (or `<A-Left>`) to return. Try `gr` to list all references.
- Repeat in `practice.cpp`: `gd` on `Point`, then `K` on `std::sqrt`.

### Drill 16 — Rename a symbol everywhere
**File:** `practice.py`. **Goal:** safe project-wide rename.
- Cursor on `calc`. `<leader>rn`, type `area_of_circle`, `<CR>`.
- Confirm every call site updated. Undo with `u` if you want to redo it.

### Drill 17 — Autocomplete a method name
**File:** `practice.py`. **Goal:** let the LSP spell it for you.
- On a new line type `math.` and read the popup.
- Pick `sqrt` with `<C-n>`/`<C-p>`, accept with `<CR>`. Use `K` for its docs.

### Drill 18 — Format on save
**Files:** `practice.py`, `refactor-me.js`, `practice.cpp`. **Goal:** auto-format.
- Find a badly-spaced line (e.g. `total=0`, or the `config={...}` line).
- `<leader>w` to save — it reformats. Or `<leader>cf` to format on demand.

---

## Tier 5 — Bulk power (mastery)

### Drill 19 — Multiple cursors
**File:** `refactor-me.js`, the `process(items)` function. **Goal:** VS Code-style.
- Cursor on `item`. `<C-n>` repeatedly to select each occurrence (or `<leader>A`
  for all).
- `c` `entry` `<Esc>` to change them all at once.

### Drill 20 — Record and replay a macro
**File:** `practice.py`, the `# alpha / # beta / # gamma` lines. **Goal:** macros.
- Uncomment them (`gc` in visual) or type three bare words.
- Cursor on the first: `qa` `I` `process("` `<Esc>` `A` `");` `<Esc>` `j` `q`.
- `2@a` to finish the rest. Try `99@a` on a longer list.

---

## Graduation checklist

You're dangerous when you can, without thinking:

- [ ] Jump to any line/word/character on screen without arrows or the mouse.
- [ ] Edit using operator + text object (`ci"`, `dap`, `yi{`).
- [ ] Open any file with `<leader>ff` and any text with `<leader>fg`.
- [ ] `gd` into a definition and `<C-o>` back, across files.
- [ ] Rename a symbol with `<leader>rn` and trust it.
- [ ] Make a repetitive edit with multi-cursor **or** a macro.
- [ ] Run a command in the terminal and search its output with `<Esc><Esc>` `/`.

When all boxes are checked, the mouse is officially optional. Keep the
[cheat sheet](02-cheatsheet.md) handy for the long tail.
