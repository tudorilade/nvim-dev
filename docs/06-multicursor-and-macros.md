# 06 — Multi-cursor & macros

[← Back to index](README.md) · Prev: [LSP & coding](05-lsp-and-coding.md) · Next: [Terminal & grep →](07-terminal-and-grep.md)

Two ways to make the same edit in many places at once: **multiple cursors**
(visual, VS Code-like) and **macros** (record once, replay anywhere — the more
powerful Vim-native tool). Learn both; reach for whichever fits.

## Multiple cursors (vim-visual-multi)

This behaves like VS Code's `Ctrl-D`.

### The core workflow

1. Put the cursor on a word.
2. Press `<C-n>` — it selects that word and creates a cursor.
3. Press `<C-n>` again — it finds the **next** occurrence and adds a cursor
   there. Repeat to keep adding.
4. Now type a command that applies to **all** cursors at once, e.g.:
   - `c` to change the word, type the replacement, `<Esc>`.
   - `i` / `a` to insert before / after each.
   - any motion/operator like `e`, `$`, `d$`.
5. `<Esc>` exits multi-cursor mode.

| Keys | Action |
|------|--------|
| `<C-n>` | select word / add cursor at next match |
| `<C-Down>` / `<C-Up>` | add a cursor on the line below / above (a column) |
| `<C-x>` | skip the current match, move to the next |
| `<C-p>` | remove the last cursor |
| `n` / `N` | go to next / previous occurrence (while in VM mode) |
| `<leader>A` | select **all** occurrences at once |
| `q` | skip current and find next (alias) |
| `<Esc>` | leave multi-cursor mode |

### Recipes

- **Rename every `count` on screen to `total`:** cursor on `count`, `<C-n>`
  a few times (or `<leader>A` for all), then `c` `total` `<Esc>`.
- **Add a cursor to a column of lines:** `<C-Down>` several times, then `A`
  to append at the end of each line, type, `<Esc>`.
- **Edit selected matches only:** `<C-n>` to grab the first, `<C-x>` to skip
  ones you don't want, `<C-n>` to grab the next.

> Multi-cursor is best for visible, on-screen edits. For repetitive edits across
> a whole file or many files, macros (below) or `cgn` + `.` are often better.

## The quick `cgn` + `.` trick (no plugin)

A lightweight alternative to multi-cursor for "change this word again and again":

1. Cursor on the word → `*` (searches for it, jumps to next).
2. `cgn`, type the replacement, `<Esc>` (changes the next match).
3. `.` to repeat on the next match, or `n` to skip one.

Because it uses dot-repeat, you stay in full control match by match.

## Macros (record & replay)

A macro records your exact keystrokes into a register and replays them. This is
the most powerful repetition tool in Vim — it can do anything you can type.

### Recording

| Keys | Action |
|------|--------|
| `q<letter>` | start recording into register `<letter>` (e.g. `qa`) |
| …your edits… | everything you type is recorded |
| `q` | stop recording |
| `@<letter>` | replay the macro (e.g. `@a`) |
| `@@` | replay the **last** macro again |
| `5@a` | replay macro `a` five times |

### The golden rule of macros

Make each macro **self-contained and repeatable**: start by normalizing the
cursor position (e.g. `0` to go to column 0), do the edit, then move to the
**start of the next target** (e.g. `j`). That way `@a` works from wherever it
lands, and `99@a` runs it down the whole file safely.

### Worked example — turn a list into a function call

Starting lines:

```
alpha
beta
gamma
```

Goal:

```
process("alpha");
process("beta");
process("gamma");
```

Record (cursor on `alpha`):

1. `qa` — start recording into `a`.
2. `I` `process("` `<Esc>` — insert the prefix.
3. `A` `");` `<Esc>` — append the suffix.
4. `j` — move to the next line (sets up the repeat).
5. `q` — stop.

Now `2@a` finishes the other two lines. Or `99@a` to blast through a long list
(it stops harmlessly when there are no more lines).

### Editing a macro

A macro is just text in a register, so you can fix it:

1. `:put a` — paste the contents of macro `a` into the buffer.
2. Edit the keystrokes.
3. `"ayy` (or `0"ay$`) — yank the corrected line back into register `a`.

## Column / block editing (visual block)

For rectangular edits without any plugin:

1. `<C-v>` to start a block selection.
2. Move with `j`/`k` to cover the rows, `l`/`$` for columns.
3. `I` (insert before) or `A` (append after), type your text, `<Esc>` — it
   applies to every row.
4. `d` deletes the block; `c` changes it; `r<x>` replaces every char with `x`.

Practice with [Drills 19–20](10-practice-drills.md).
