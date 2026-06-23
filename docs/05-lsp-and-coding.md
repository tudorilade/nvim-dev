# 05 — LSP & coding (IDE features)

[← Back to index](README.md) · Prev: [Navigation & search](04-navigation-and-search.md) · Next: [Multi-cursor & macros →](06-multicursor-and-macros.md)

This setup turns Neovim into a real IDE using the **Language Server Protocol
(LSP)**. You get autocomplete, go-to-definition, rename, diagnostics, and
formatting for every configured language.

## What's configured out of the box

| Language | Server | Formatter |
|----------|--------|-----------|
| Python | basedpyright | ruff (→ black fallback) |
| C / C++ | clangd | clang-format |
| JavaScript / TypeScript | ts_ls | prettier |
| HTML / CSS / JSON | html, cssls, jsonls | prettier |
| Rust | rust-analyzer | rustfmt (via LSP) |
| Lua | lua_ls | stylua |
| Bash / shell | bashls | shfmt |

The servers and formatters are installed automatically by `setup.sh` (via
[Mason](11-troubleshooting.md#mason)). On first open of a new language, Mason may
take a few seconds to finish installing — check progress with `:Mason`.

## Autocomplete

Completion (powered by [nvim-cmp]) pops up as you type. It suggests method
names, variables, snippets, and file paths from the language server.

| Keys | Action |
|------|--------|
| (just type) | suggestions appear automatically |
| `<C-Space>` | force the menu open / show docs |
| `<C-n>` / `<C-p>` | next / previous suggestion |
| `<Tab>` | accept suggestion **or** jump to next snippet placeholder |
| `<CR>` | accept the highlighted suggestion |
| `<C-e>` | dismiss the menu |
| `<C-d>` / `<C-u>` | scroll the documentation popup |

There's also **ghost text**: a faint inline preview of the top suggestion. Hit
`<Tab>` to accept it.

> Want the exact spelling of a method? Type the object and `.` and the menu lists
> every available method with its signature and docs.

## Navigating code

| Keys | Action |
|------|--------|
| `gd` | **Go to definition** (opens the other file if needed) |
| `gD` | go to declaration |
| `gr` | list all **references** (in Telescope) |
| `gi` | go to implementation |
| `gy` | go to type definition |
| `<C-o>` / `<A-Left>` | jump **back** (see [jumplist](04-navigation-and-search.md#the-jumplist--go-to-definition-back-and-forward)) |
| `<C-i>` / `<A-Right>` | jump **forward** |
| `<leader>fs` | fuzzy list of symbols in this file |
| `<leader>fS` | symbols across the whole workspace |

The classic loop: `gd` to dive into a definition, read it, `<C-o>` to come back.

## Understanding code

| Keys | Action |
|------|--------|
| `K` | hover: type signature + documentation |
| `gK` or `<C-k>` (insert) | signature help (parameter hints) |
| `<leader>th` | toggle inline **inlay hints** (parameter & type hints) |

While the cursor sits on a symbol, every other use of it in the file is
highlighted automatically.

## Refactoring & fixes

| Keys | Action |
|------|--------|
| `<leader>rn` | **rename** the symbol everywhere (project-wide, safely) |
| `<leader>ca` | **code action** / quick fix (imports, fixes, refactors) |
| `<leader>cf` | format the buffer now |

`<leader>ca` is context-sensitive — it offers things like "import this name",
"remove unused", "extract variable", or whatever the language server supports.

## Diagnostics (errors & warnings)

Problems show up inline with an icon in the gutter and squiggly underlines.

| Keys | Action |
|------|--------|
| `]d` / `[d` | next / previous diagnostic |
| `<leader>cd` | show the full message for the current line |
| `<leader>xx` | open the diagnostics list ([Trouble](09-keybindings-reference.md)) |
| `<leader>xX` | diagnostics for this buffer only |
| `<leader>fd` | fuzzy-search all diagnostics |

## Formatting on save

Every supported file is auto-formatted when you save (`<leader>w`). To control
it:

| Command | Effect |
|---------|--------|
| `:FormatDisable` | turn off format-on-save (this session) |
| `:FormatDisable!` | turn it off for the current buffer only |
| `:FormatEnable` | turn it back on |
| `<leader>cf` | format right now, on demand |

## Managing the tooling

| Command | Purpose |
|---------|---------|
| `:Mason` | UI to install/update/remove servers & formatters |
| `:MasonInstallAll` | install everything this config wants (run by setup.sh) |
| `:LspInfo` | show which servers are attached to the buffer |
| `:checkhealth lsp` | diagnose LSP problems |
| `:ConformInfo` | see which formatters apply to this file |

If `gd`/`K`/autocomplete aren't working in a file, see
[Troubleshooting → LSP not attaching](11-troubleshooting.md#lsp-not-attaching).

Practice with [Drills 15–18](10-practice-drills.md) using
[`practice/practice.py`](practice/practice.py) and
[`practice/practice.cpp`](practice/practice.cpp).

[nvim-cmp]: https://github.com/hrsh7th/nvim-cmp
