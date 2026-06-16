# nvim-dev — an "extraordinary Vim developer" Neovim setup

A self-contained, mouse-free Neovim IDE you can install on any Linux box, macOS,
or WSL with **one command**. Clone the repo, run `./setup.sh`, and from then on
typing `vim` or `nvim` drops you into a fully configured editor with LSP
autocomplete, go-to-definition with jump-back, multi-cursors, an integrated
searchable terminal, project-wide ripgrep search, hybrid line numbers, and a
calm dark-blue theme.

```bash
git clone <your-repo-url> ~/nvim-dev
cd ~/nvim-dev
./setup.sh
# open a new shell, then:
vim
```

That's it. The first launch finishes downloading plugins and language servers
automatically (the setup script also pre-warms them headlessly).

---

## Why this exists

The goal is to never reach for the mouse again and to write code as fast as you
can think. Everything a great Vim developer leans on is preconfigured and,
crucially, **documented and practiceable** in [`docs/`](docs/README.md).

## What you get

- **Hybrid line numbers** — absolute current line, relative above/below so
  `10j` / `8k` are trivial.
- **Go to definition + jump back** — `gd` jumps (opening another file if
  needed), `Ctrl-o` / `Alt-Left` goes back, `Ctrl-i` / `Alt-Right` forward —
  just like VS Code.
- **IDE autocomplete** for Python, C/C++, JS/TS + web, Rust, Lua, and Bash via
  LSP + [blink.cmp], with format-on-save.
- **Multiple cursors** (`Ctrl-n`, VS Code style) and **word swapping**
  (`cx` / `cxiw`).
- **Integrated terminal** (`Ctrl-\`) you can scroll and search with the keyboard
  like a normal buffer (Emacs-style).
- **Project search**: `grep`-style live search from the current directory,
  browse results, and open the file at the exact line in ~4 keystrokes.
- **Fuzzy everything**: files, buffers, symbols, help — all via Telescope.
- **On-screen jumps** with flash (`s`), a file explorer (`<leader>e`), git
  integration (gitsigns + lazygit), and live keybinding hints (which-key) so you
  never have to memorize anything cold.

A complete feature → keys map lives in
[docs/09-keybindings-reference.md](docs/09-keybindings-reference.md).

---

## Top 15 keys to start with

> Leader key is **Space**.

| Keys | Does |
|------|------|
| `<Space>` then wait | Show every leader shortcut (which-key) |
| `<Space>ff` | Find files (fuzzy) |
| `<Space>fg` | Live grep the whole project |
| `<Space>fw` | Grep the word under the cursor |
| `<Space>e` | Toggle file explorer |
| `gd` | Go to definition |
| `Ctrl-o` / `Alt-Left` | Jump back |
| `K` | Hover docs |
| `<Space>rn` | Rename symbol everywhere |
| `<Space>ca` | Code action / quick fix |
| `Ctrl-n` | Add cursor at next match (multi-cursor) |
| `Ctrl-\` | Toggle integrated terminal |
| `s` | Flash jump anywhere on screen |
| `<Space>gg` | Open lazygit |
| `gc` | Comment / uncomment |

---

## Documentation & practice

Everything is in [`docs/`](docs/README.md). Start there — it doubles as a cheat
sheet and a hands-on training course:

- [Getting started](docs/01-getting-started.md)
- [One-page cheat sheet](docs/02-cheatsheet.md)
- [Motions & editing](docs/03-motions-and-editing.md)
- [Navigation & search](docs/04-navigation-and-search.md)
- [LSP & coding](docs/05-lsp-and-coding.md)
- [Multi-cursor & macros](docs/06-multicursor-and-macros.md)
- [Terminal & grep](docs/07-terminal-and-grep.md)
- [Git](docs/08-git.md)
- [Keybindings reference](docs/09-keybindings-reference.md)
- [Practice drills](docs/10-practice-drills.md)
- [Troubleshooting](docs/11-troubleshooting.md)
- [Dependencies (full deploy)](docs/12-dependencies.md)

Practice files to drill on live in [docs/practice/](docs/practice/).

---

## What `setup.sh` does

1. Detects your OS and package manager (`apt`, `dnf`, `pacman`, or `brew`).
2. Installs dependencies: Neovim (>= 0.11), ripgrep, fd, git, a C compiler,
   make, unzip, curl, Node.js, and Python 3.
3. Backs up any existing `~/.config/nvim` then symlinks this repo's `nvim/`
   directory into place.
4. Adds `alias vim=nvim` and sets `EDITOR` in your shell rc (`.bashrc` /
   `.zshrc`).
5. Bootstraps plugins and language servers headlessly so the first real launch
   is instant.

It is **idempotent** — safe to re-run any time to update or repair the install.

### Requirements

- A Unix-like shell (Linux, macOS, or WSL). Native Windows users can use the
  thin `setup.ps1` helper, but the supported path is `setup.sh`.
- `sudo` access for installing system packages (or run as a user that can).

---

## Customizing

- **Theme**: edit `nvim/lua/plugins/colorscheme.lua` (default is
  `tokyonight-storm`; `kanagawa` and `catppuccin-macchiato` are documented
  alternatives).
- **Keymaps**: `nvim/lua/config/keymaps.lua`.
- **Options**: `nvim/lua/config/options.lua`.
- **Add/remove plugins**: drop a file in `nvim/lua/plugins/` — lazy.nvim picks
  it up automatically.
- **Machine-local tweaks**: create `nvim/lua/config/local.lua` (gitignored) and
  it is sourced automatically if present.

---

## Publishing to GitHub

```bash
cd ~/nvim-dev
git init
git add .
git commit -m "Initial nvim-dev setup"
gh repo create nvim-dev --public --source=. --remote=origin --push
```

(Replace `nvim-dev` with whatever you want to call it.)

[blink.cmp]: https://github.com/Saghen/blink.cmp
