# 12 — Dependencies

Everything needed for a **full** nvim-dev install: system packages, user-local
tools, Mason language servers, treesitter parsers, and Neovim plugins.

**Entry point:** `./setup.sh` from the repo root (or `./setup.sh --no-deps` to
skip apt and only link config + bootstrap Lazy).

After first interactive launch, run once inside nvim:

```vim
:MasonInstallAll
```

---

## System packages (apt — Ubuntu 22.04 & 24.04)

Installed by `./setup.sh` when **not** using `--no-deps`.


| Package           | Required    | Purpose                                                         |
| ----------------- | ----------- | --------------------------------------------------------------- |
| `git`             | yes         | Clone Lazy.nvim and all plugins                                 |
| `curl`            | yes         | Download Neovim tarball, tree-sitter, Mason artifacts           |
| `wget`            | yes         | Fallback downloads                                              |
| `unzip`           | yes         | Archives                                                        |
| `tar`             | yes         | Neovim / parser tarballs                                        |
| `ripgrep` (`rg`)  | yes         | `<leader>fg` live grep, `:grep`                                 |
| `fd-find`         | yes         | Telescope find files (setup symlinks → `~/.local/bin/fd`)       |
| `build-essential` | yes         | `gcc`, `make` — telescope-fzf-native, treesitter parser compile |
| `python3`         | yes         | Python development                                              |
| `python3-pip`     | recommended | Python tooling                                                  |
| `python3-venv`    | recommended | Virtual environments                                            |
| `nodejs`          | yes         | Mason **basedpyright** (needs Node)                             |
| `npm`             | yes         | Same                                                            |
| `xclip`           | optional    | System clipboard over SSH (`+y` / `+p`); skip on pure headless  |


**One-liner (22.04 or 24.04):**

```bash
sudo apt update && sudo apt install -y \
  git curl wget unzip tar ripgrep fd-find build-essential \
  python3 python3-pip python3-venv nodejs npm xclip
```

---

## Ubuntu version-specific differences


| Item                        | Ubuntu **22.04** jammy                                                                                                | Ubuntu **24.04** noble                                           |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| **glibc**                   | 2.35                                                                                                                  | 2.39                                                             |
| **Neovim**                  | apt often **0.6.x** → setup installs **0.12 tarball** to `~/.local/nvim`                                              | apt may be new enough; tarball fallback if too old               |
| **tree-sitter CLI**         | **cargo build** first (`cargo install tree-sitter-cli`); fallback pins `0.22.6`, `0.20.8` — **never** GitHub `latest` | GitHub **latest** prebuilt OK; pins `latest`, `0.26.9`, `0.24.7` |
| **Extra apt (tree-sitter)** | `cargo`, `rustc`, `build-essential` (auto-installed by setup when `DO_DEPS=1`)                                        | Usually **not** needed for tree-sitter                           |
| **Clipboard**               | `xclip` if you want `+` register over SSH                                                                             | Same                                                             |
| **Mason / plugins**         | Identical                                                                                                             | Identical                                                        |
| **Python indent**           | `GetPythonIndent()` (built-in)                                                                                        | Same                                                             |
| **lazygit**                 | GitHub binary → `~/.local/bin` (jammy has no apt package)                                                             | apt `lazygit` when available, else same binary install           |


**22.04 — extra apt for treesitter CLI:**

```bash
sudo apt install -y cargo rustc build-essential
```

**24.04 — tree-sitter only (if setup did not install it):**

```bash
# setup.sh downloads prebuilt to ~/.local/bin/tree-sitter automatically
tree-sitter --version   # must run without GLIBC errors
```

**Detect your Ubuntu version:**

```bash
. /etc/os-release && echo "$VERSION_ID $VERSION_CODENAME"
# 22.04 jammy  or  24.04 noble
```

---

## User-local binaries (`~/.local/bin`)


| Binary        | Min version                          | How installed                                   | Notes                                               |
| ------------- | ------------------------------------ | ----------------------------------------------- | --------------------------------------------------- |
| `nvim`        | **≥ 0.11** (config targets **0.12**) | apt or official tarball via `install/neovim.sh` | Symlinked to `~/.local/bin/nvim` when using tarball |
| `tree-sitter` | **≥ 0.26.1** (nvim-treesitter main)  | cargo build (22.04) or GitHub release (24.04)   | Required to compile treesitter parsers              |
| `fd`          | any recent                           | Symlink from `fdfind` on Debian/Ubuntu          | Used by Telescope `find_files`                      |
| `lazygit`     | any recent                           | apt (24.04) or GitHub release via `install/lazygit.sh` | Git TUI — `<leader>gg`, `<leader>tg`          |


**Avoid:** `~/.local/share/nvim/mason/bin/tree-sitter` — wrong version; setup removes it.

---

## Optional system tools (if setup failed)


| Tool                        | Purpose                                          | Install                                                          |
| --------------------------- | ------------------------------------------------ | ---------------------------------------------------------------- |
| `rustc` / `cargo`           | Rust **projects** (not just `rust-analyzer` LSP) | `sudo apt install rustc cargo`                                   |
| `clang` / `clangd` (system) | C++ projects if not using Mason-only             | `build-essential` + Mason `clangd`                               |

`lazygit` is installed by `./setup.sh` (apt when available, else `~/.local/bin/lazygit` from GitHub).


---

## Mason — language servers (`:MasonInstallAll`)

Installed into `~/.local/share/nvim/mason/` on first run.


| Mason package   | Languages / role                             |
| --------------- | -------------------------------------------- |
| `basedpyright`  | Python — completion, types, go-to-definition |
| `ruff`          | Python — lint + format (LSP)                 |
| `clangd`        | C / C++                                      |
| `ts_ls`         | JavaScript / TypeScript                      |
| `html`          | HTML                                         |
| `cssls`         | CSS                                          |
| `jsonls`        | JSON / JSONC                                 |
| `rust_analyzer` | Rust                                         |
| `lua_ls`        | Lua / Neovim config                          |
| `bashls`        | Bash / shell                                 |


**Requires Node on host:** `basedpyright` (and Mason’s own installer).

---

## Mason — formatters & tools (`:MasonInstallAll`)


| Mason package  | Used for                                            |
| -------------- | --------------------------------------------------- |
| `stylua`       | Lua format (`<leader>cf`)                           |
| `prettier`     | JS/TS/HTML/CSS/JSON/Markdown format                 |
| `clang-format` | C/C++ format                                        |
| `shfmt`        | Shell format                                        |
| `black`        | Python format (fallback if ruff format unavailable) |


---

## Treesitter parsers (nvim-treesitter `main`)

Requires a **working** `tree-sitter` CLI on `PATH`.

**Installed at setup (headless `TSInstall!`):**


| Parser   | Why                                                                        |
| -------- | -------------------------------------------------------------------------- |
| `vim`    | Cmdline / noice highlighting; fixes `invalid node type "tab"` when matched |
| `vimdoc` | `:help` treesitter                                                         |
| `python` | Syntax highlight                                                           |
| `lua`    | Config / Lua files                                                         |
| `bash`   | Shell scripts                                                              |
| `json`   | JSON configs                                                               |


**Installed on demand** when you open a file (if CLI works):

`c`, `cpp`, `rust`, `javascript`, `typescript`, `tsx`, `html`, `css`, `jsonc`,
`yaml`, `toml`, `markdown`, `markdown_inline`, `vimdoc`, `regex`, `diff`,
`gitcommit`, `gitignore`, `dockerfile`, `luadoc`, …

**Without tree-sitter CLI:** Neovim still runs. You lose treesitter highlighting
and text objects (`]f`, `af`, …). Python `o` / Enter indent still works via
`GetPythonIndent()`.

---

## Neovim plugins (all Ubuntu versions)

Installed by **Lazy.nvim** into `~/.local/share/nvim/lazy/` on `:Lazy sync`.
Branch/commit pinned in `nvim/lazy-lock.json`.


| Plugin                        | Repository                                                     | Role                                         |
| ----------------------------- | -------------------------------------------------------------- | -------------------------------------------- |
| lazy.nvim                     | folke/lazy.nvim                                                | Plugin manager                               |
| nvim-cmp                      | hrsh7th/nvim-cmp                                               | Autocomplete (LSP)                             |
| cmp-nvim-lsp                  | hrsh7th/cmp-nvim-lsp                                           | LSP source for nvim-cmp                        |
| friendly-snippets             | rafamadriz/friendly-snippets                                   | Snippet definitions                          |
| mason.nvim                    | williamboman/mason.nvim                                        | LSP/formatter installer                      |
| mason-lspconfig.nvim          | williamboman/mason-lspconfig.nvim                              | LSP ↔ Mason bridge                           |
| mason-tool-installer.nvim     | WhoIsSethDaniel/mason-tool-installer.nvim                      | Batch Mason installs                         |
| nvim-lspconfig                | neovim/nvim-lspconfig                                          | LSP server configs                           |
| fidget.nvim                   | j-hui/fidget.nvim                                              | LSP progress in statusline                   |
| conform.nvim                  | stevearc/conform.nvim                                          | Format on save / `<leader>cf`                |
| nvim-treesitter               | nvim-treesitter/nvim-treesitter (**branch: main**)             | Parser install + queries                     |
| nvim-treesitter-textobjects   | nvim-treesitter/nvim-treesitter-textobjects (**branch: main**) | `af`/`if`, `]f`/`[f`, etc.                   |
| telescope.nvim                | nvim-telescope/telescope.nvim                                  | Fuzzy find, live grep, buffers               |
| telescope-fzf-native.nvim     | nvim-telescope/telescope-fzf-native.nvim                       | Fast Telescope sorter (needs `make`)         |
| plenary.nvim                  | nvim-lua/plenary.nvim                                          | Lua utilities (Telescope, etc.)              |
| flash.nvim                    | folke/flash.nvim                                               | On-screen jump (`s`)                         |
| tokyonight.nvim               | folke/tokyonight.nvim                                          | Default colorscheme (storm)                  |
| kanagawa.nvim                 | rebelot/kanagawa.nvim                                          | Alt theme (`<leader>ft`)                     |
| catppuccin                    | catppuccin/nvim                                                | Alt theme                                    |
| lualine.nvim                  | nvim-lualine/lualine.nvim                                      | Statusline                                   |
| bufferline.nvim               | akinsho/bufferline.nvim                                        | Buffer tabs                                  |
| which-key.nvim                | folke/which-key.nvim                                           | Keybinding hints (`<leader>`)                |
| indent-blankline.nvim         | lukas-reineke/indent-blankline.nvim                            | Indent guides                                |
| noice.nvim                    | folke/noice.nvim                                               | Cmdline / messages UI                        |
| nui.nvim                      | MunifTanjim/nui.nvim                                           | UI primitives (noice)                        |
| nvim-notify                   | rcarriga/nvim-notify                                           | Notifications                                |
| dashboard-nvim                | nvimdev/dashboard-nvim                                         | Startup screen                               |
| trouble.nvim                  | folke/trouble.nvim                                             | Diagnostics / quickfix UI                    |
| todo-comments.nvim            | folke/todo-comments.nvim                                       | TODO/FIXME highlight + search                |
| persistence.nvim              | folke/persistence.nvim                                         | Session restore                              |
| nvim-web-devicons             | nvim-tree/nvim-web-devicons                                    | File icons                                   |
| vim-visual-multi              | mg979/vim-visual-multi                                         | Multi-cursor (`Ctrl-d`)                      |
| vim-exchange                  | tommcdo/vim-exchange                                           | Swap two text regions (`cx`)                 |
| nvim-surround                 | kylechui/nvim-surround                                         | Add/change/delete surrounds                  |
| Comment.nvim                  | numToStr/Comment.nvim                                          | Comment toggles (`gcc`, `gc`)                |
| nvim-autopairs                | windwp/nvim-autopairs                                          | Auto-close brackets                          |
| nvim-ts-context-commentstring | JoosepAlviste/nvim-ts-context-commentstring                    | JSX-aware comments                           |
| mini.ai                       | echasnovski/mini.ai                                            | Extra text objects (`ai`, `ii`)              |
| gitsigns.nvim                 | lewis6991/gitsigns.nvim                                        | Git gutter, stage hunks                      |
| lazygit.nvim                  | kdheepak/lazygit.nvim                                          | Lazygit integration (needs `lazygit` binary) |
| nvim-tree.lua                 | nvim-tree/nvim-tree.lua                                        | File explorer (`<leader>e`)                  |
| toggleterm.nvim               | akinsho/toggleterm.nvim                                        | Integrated terminal (`Ctrl-\`)               |


**Total:** 41 plugins (including theme alternates and Lazy itself).

---

## Full deploy checklist

### Ubuntu 22.04 (jammy)

```bash
sudo apt update
sudo apt install -y git curl wget unzip tar ripgrep fd-find build-essential \
  python3 python3-pip python3-venv nodejs npm xclip cargo rustc

git clone <repo> ~/nvim-dev && cd ~/nvim-dev
./setup.sh
source ~/.bashrc

tree-sitter --version          # no GLIBC error
nvim --headless "+TSInstall! vim" "+TSInstall! vimdoc" "+TSInstall python lua bash json" +qa
nvim -c MasonInstallAll -c qa
```

### Ubuntu 24.04 (noble)

```bash
sudo apt update
sudo apt install -y git curl wget unzip tar ripgrep fd-find build-essential \
  python3 python3-pip python3-venv nodejs npm xclip

git clone <repo> ~/nvim-dev && cd ~/nvim-dev
./setup.sh
source ~/.bashrc

tree-sitter --version
nvim -c MasonInstallAll -c qa
```

### Config-only (deps already present)

```bash
cd ~/nvim-dev && git pull && ./setup.sh --no-deps
```

---

## What still works if something is missing


| Missing            | Still works                                    | Degraded                                   |
| ------------------ | ---------------------------------------------- | ------------------------------------------ |
| `tree-sitter` CLI  | LSP, completion, grep, terminal, Python indent | TS highlight, `]f`/`af`, fancy `:` cmdline |
| `xclip`            | Internal yank/paste (`"`)                      | System clipboard (`+`)                     |
| `ripgrep`          | `:grep`, basic search                          | `<leader>fg` live grep                     |
| `fd`               | Telescope with slower fallback                 | Fast `<leader>ff`                          |
| `nodejs`           | Editing plain files                            | `basedpyright` / Mason pyright             |
| `lazygit`          | `gitsigns`, terminal `git`                     | `<leader>gg`, `<leader>tg`                 |
| `:MasonInstallAll` | Editing                                        | `gd`, autocomplete, format-on-save         |


See also [11 — Troubleshooting](11-troubleshooting.md).