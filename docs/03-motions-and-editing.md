# 03 — Motions & editing

[← Back to index](README.md) · Prev: [Cheat sheet](02-cheatsheet.md) · Next: [Navigation & search →](04-navigation-and-search.md)

This is the single most valuable page. Once the **operator + motion** grammar
clicks, you stop memorizing commands and start *composing* them.

## The grammar: verb + noun

Most edits are an **operator** (a verb) plus a **motion** or **text object**
(a noun):

```
  operator   +   motion/text-object
  --------       -----------------
  d (delete)     w  (to next word)      ->  dw
  c (change)     iw (inner word)        ->  ciw
  y (yank/copy)  ap (a paragraph)       ->  yap
  >  (indent)    i{ (inside braces)     ->  >i{
```

Learn a handful of operators and a handful of motions, and you get their product
for free.

### Operators (verbs)

| Operator | Meaning |
|----------|---------|
| `d` | delete (cut) |
| `c` | change (delete then insert) |
| `y` | yank (copy) |
| `>` `<` | indent / dedent |
| `=` | auto-indent |
| `gu` `gU` | lowercase / uppercase |
| `gc` | toggle comment |

Doubling an operator acts on the whole line: `dd`, `cc`, `yy`, `>>`.

### Motions (nouns that move)

| Motion | Moves to |
|--------|----------|
| `w` / `W` | start of next word / WORD |
| `b` / `B` | back a word / WORD |
| `e` / `ge` | end of word / previous end |
| `0` / `^` / `$` | line start / first non-blank / line end |
| `f<x>` / `F<x>` | next / previous `x` on the line |
| `t<x>` / `T<x>` | just before next / previous `x` |
| `;` / `,` | repeat / reverse the last `f t F T` |
| `}` / `{` | next / previous paragraph |
| `%` | matching `()[]{}` |
| `gg` / `G` | first / last line |
| `H` `M` `L` | top / middle / bottom of screen |

> `w` stops at punctuation; `W` treats whitespace-separated chunks as one word.
> Same idea for `b/B` and `e/E`.

## Text objects (nouns that select a region)

Text objects are the superpower. They come in `i` (inner) and `a` (around)
flavors and work with any operator:

| Object | Selects |
|--------|---------|
| `iw` / `aw` | inner word / a word (with surrounding space) |
| `is` / `as` | sentence |
| `ip` / `ap` | paragraph |
| `i"` `i'` `` i` `` | inside quotes |
| `i(` `i[` `i{` | inside brackets (also `ib` / `iB`) |
| `it` / `at` | inside / around an HTML/XML tag |
| `if` / `af` | inside / around a function (treesitter) |
| `ic` / `ac` | inside / around a class (treesitter) |
| `ia` / `aa` | inner / a function argument (treesitter) |

Examples:

- `ci"` — change everything inside the quotes (cursor anywhere on the line).
- `dap` — delete this whole paragraph.
- `yi{` — copy everything inside the current `{ }` block.
- `vif` — visually select the current function body.
- `cia` — change the function argument you're inside of.

## Dot-repeat: your free macro

`.` repeats your last change. This is huge when combined with a motion.

Example — append `;` to several lines:

1. `A;` then `<Esc>` (append `;` at end of line).
2. Move to the next line (`j`).
3. Press `.` to repeat. Keep `j .` `j .`.

Example — change every `foo` to `bar`, deciding case by case:

1. `*` to search for the word under the cursor.
2. `cgn` then type `bar`, `<Esc>` (change the next match).
3. `n` to skip or `.` to apply to the next match.

## Surround (add/change/delete brackets & quotes)

Powered by nvim-surround. Mnemonics: **ys** = "you surround", **cs** = "change
surround", **ds** = "delete surround".

| Keys | Before → After |
|------|----------------|
| `ysiw"` | `word` → `"word"` |
| `ysiw)` | `word` → `(word)` |
| `yss"` | surround the whole line |
| `cs"'` | `"word"` → `'word'` |
| `cs([` | `(word)` → `[ word ]` |
| `ds"` | `"word"` → `word` |
| `S"` (visual) | wrap the selection in `"` |
| `ysiwt` then `em>` | wrap word in `<em>…</em>` |

## Comments

| Keys | Action |
|------|--------|
| `gcc` | toggle comment on the current line |
| `gc` (visual) | toggle comment on the selection |
| `gcap` | comment the whole paragraph |
| `gcj` | comment this line and the one below |

Comment strings are language-aware, so it does the right thing in JSX, Lua, C++,
etc.

## Swapping / exchanging text

Two ways, depending on what you want:

**Swap the current word with the next** (quick, one key):

- `<leader>sw` — swaps `alpha beta` into `beta alpha` keeping the cursor put.

**Exchange two arbitrary spots** (vim-exchange) — great for swapping function
arguments or list items that aren't adjacent:

1. Put the cursor on the first word, type `cxiw` (mark it for exchange).
2. Move to the second word, type `cxiw` again. They swap.

Variants: `cxx` exchanges whole **lines** (do it on two lines); in visual mode
select a region and press `X` to exchange it with the next `X` selection. `cxc`
cancels a pending exchange.

## Visual mode tricks

| Keys | Action |
|------|--------|
| `v` / `V` / `<C-v>` | char / line / block selection |
| `viw` | select inner word |
| `gv` | reselect the last selection |
| `o` | jump to the other end of the selection |
| `J` (visual) | move selected lines **down** |
| `K` (visual) | move selected lines **up** |
| `>` / `<` (visual) | indent / dedent and keep selection |
| `<C-v>` then `I`/`A` then `<Esc>` | insert on every line of the block |

## Registers & clipboard

- Yanks go to the **system clipboard** by default (`y` then paste anywhere).
- `"ayy` yanks the line into register `a`; `"ap` pastes from it.
- `"0p` pastes the last *yank* (not affected by deletes).
- `<leader>p` (visual) pastes over a selection without losing your yank.
- `<leader>d` deletes to the black hole register (doesn't touch the clipboard).

Practice all of this with [Drills 5–9](10-practice-drills.md) on
[`practice/refactor-me.js`](practice/refactor-me.js).
