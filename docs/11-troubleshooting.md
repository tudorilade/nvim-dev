# 11 — Troubleshooting

[← Back to index](README.md) · Prev: [Practice drills](10-practice-drills.md)

Fixes for the things that actually go wrong. When in doubt, run the built-in
health check first:

```vim
:checkhealth
```

It reports missing executables, broken providers, and plugin problems with
specific advice.

## `vim` still opens the old Vim, not Neovim

The shell alias is added to `~/.bashrc` / `~/.zshrc`, but the current shell
hasn't reloaded it.

```bash
source ~/.bashrc      # or open a new terminal
which vim             # should print an alias to nvim
```

If it still doesn't, make sure your shell actually sources `~/.bashrc`. On macOS,
login shells read `~/.bash_profile` — setup.sh chains it to `~/.bashrc`, but if
you customized it, add `[ -r ~/.bashrc ] && . ~/.bashrc` yourself.

## `nvim: command not found` after setup

Neovim was installed to `~/.local/bin` (the no-sudo fallback). Make sure that's
on your PATH:

```bash
echo $PATH | tr ':' '\n' | grep -q "$HOME/.local/bin" && echo ok || echo missing
export PATH="$HOME/.local/bin:$PATH"   # setup.sh adds this to your rc too
```

Open a new terminal so the rc change takes effect.

## Plugins didn't install / errors on first launch

Re-run the sync manually:

```vim
:Lazy sync
```

Then restart. To inspect, `:Lazy` opens the manager UI (press `?` for help). If a
single plugin is broken, select it and press `r` to reinstall, or `x` to clean.

## LSP not attaching

Symptoms: no autocomplete, `gd`/`K` do nothing, no diagnostics.

1. Check what's attached: `:LspInfo`.
2. Check the server is installed: `:Mason` — find the server for your language
   (e.g. `basedpyright`, `clangd`, `rust-analyzer`). Press `i` to install if it
   isn't.
3. Install everything this config wants in one go:

```vim
:MasonInstallAll
```

4. Health check: `:checkhealth lsp` and `:checkhealth mason`.
5. Make sure the language's toolchain exists on PATH (e.g. `node` for ts_ls,
   `cargo` for rust-analyzer, a C compiler for clangd). `:checkhealth` will say.
6. Reopen the file (`:e`) to re-trigger attachment.

<a id="mason"></a>
### Mason install failures

- Mason needs network access plus the right runtime: `node`/`npm` for many
  servers, `python3`/`pip` for Python tools, `cargo` for Rust, `go` for Go
  tools. Install the missing runtime, then `:Mason` → reinstall.
- Behind a proxy? Set `HTTPS_PROXY` in your shell before launching nvim.
- See logs: `:MasonLog`.

## Treesitter errors / no syntax highlighting

A parser may be missing or failed to compile (compiling needs a C compiler).

```vim
:TSUpdate
:TSInstall python    " or your language
:checkhealth nvim-treesitter
```

Ensure `gcc`/`clang` and `make` are installed (`setup.sh` installs these).

## Clipboard doesn't work (WSL, SSH, headless)

By default yanks use the system clipboard (`unnamedplus`).

### SSH from your laptop (remote nvim → local clipboard)

When you SSH into a server, `xclip` on the **server** only fills the **server**
clipboard — not your laptop. The config detects SSH (`$SSH_TTY`) and uses
**OSC 52**: yanks are sent as an escape sequence through the terminal to your
**local** clipboard.

**Requirements on your laptop terminal:**

- **Windows Terminal**, **Cursor** terminal, **iTerm2**, **WezTerm**, or similar
  (must support OSC 52 — most modern terminals do)
- If you use **tmux** on the server, add to `~/.tmux.conf`:
  ```tmux
  set -g set-clipboard on
  ```

**Verify after `git pull` + reopen nvim on SSH:**

```vim
:echo g:clipboard          " should be "osc52" (string)
:echo $SSH_TTY             " should show a path, not empty
:set clipboard?            " unnamedplus
```

Plain `y` / `yy` should copy to your laptop. If not, use **`gy`** in normal/visual mode
(explicit laptop yank). Paste locally with **Ctrl+V**.

**If you use tmux on the server**, add to `~/.tmux.conf`:

```tmux
set -g set-clipboard on
```

**Cursor / Windows Terminal:** OSC 52 should work out of the box. If `gy` works but
plain `y` does not, run `:echo g:clipboard` and report the value.

**Paste from laptop → remote nvim:** **Ctrl+Shift+V** in the terminal (not `p` unless
OSC 52 paste works in your terminal).

### WSL

On WSL, install **win32yank** so nvim talks to the Windows clipboard:

```bash
curl -fsSLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > ~/.local/bin/win32yank.exe
chmod +x ~/.local/bin/win32yank.exe
```

  The config auto-detects `win32yank.exe` on WSL and routes the clipboard
  through it. Restart nvim.

### Headless server (no SSH / no display)

- Install `xclip` or `xsel` for local X clipboard, or yanks stay in nvim's `"`
  register only (on SSH, OSC 52 is used instead — see above).
- Verify: `:checkhealth` → "Clipboard" section.

## MasonInstallAll: Not an editor command

`:MasonInstallAll` is registered at startup in `config/mason_cmd.lua` (no need to
open a file first). After `git pull`, quit and reopen nvim.

```vim
:MasonInstallAll
:Mason          " watch install progress
```

Alternatives:

```vim
:MasonToolsInstall
```

LSP servers install when `lsp.lua` loads (open any file once) or via `:Mason` UI.

## Lazygit not installed

`<leader>gg` and `<leader>tg` need the **lazygit binary** (not just the nvim plugin).

```bash
cd ~/nvim-dev && git pull && ./setup.sh --no-deps
source ~/.bashrc
lazygit --version
```

Or manual install on Ubuntu 22.04 (asset name includes version — use API or setup.sh):

```bash
cd ~/nvim-dev && ./setup.sh --no-deps
# or:
TAG=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
  | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": "//;s/".*//')
VER=${TAG#v}
curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/${TAG}/lazygit_${VER}_linux_x86_64.tar.gz" \
  | tar -xz -C /tmp
install -m 0755 /tmp/lazygit_${VER}_linux_x86_64/lazygit ~/.local/bin/lazygit
```

Keys once installed:

| Key | Action |
|-----|--------|
| `<leader>gg` | Full lazygit UI (repo) |
| `<leader>gf` | Lazygit focused on current file |
| `<leader>tg` | Lazygit in float terminal |

Inside lazygit: `?` for help, `q` to quit.

## `<A-Left>` / `<A-Right>` (jump back/forward) do nothing

Some terminals don't send Alt+Arrow as Neovim expects. The native keys always
work:

- Jump back: `<C-o>`
- Jump forward: `<C-i>`

If you want the Alt keys, configure your terminal to send the right escape
sequences for Alt+Arrow, or just use `<C-o>` / `<C-i>`.

## Icons look like boxes / question marks

You need a **Nerd Font** in your terminal. Install one (e.g. "JetBrainsMono
Nerd Font") and select it in your terminal's settings. Without it, text still
works — only the little glyphs render wrong.

## Startup feels slow

- `:Lazy profile` shows what's taking time at startup.
- Most plugins here are lazy-loaded; the first launch is slower because Mason and
  Treesitter are downloading. Subsequent launches are fast.
- A huge file can be slow due to treesitter/LSP; open it with `:noautocmd e
  bigfile` to skip them.

## I broke something / want a clean slate

Plugin state lives outside the repo, so you can nuke it safely:

```bash
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

Then relaunch nvim (it re-bootstraps) or re-run `./setup.sh`. Your config in this
repo is untouched.

## Restore the config you had before installing

`setup.sh` backed up any previous config to
`~/.config/nvim.backup.<timestamp>`. To roll back:

```bash
rm ~/.config/nvim                       # remove the symlink
mv ~/.config/nvim.backup.* ~/.config/nvim
```

## Updating later

```bash
cd ~/nvim-dev && git pull && ./setup.sh   # idempotent; safe to re-run
```

Inside nvim, `:Lazy sync` updates plugins and `:Mason` updates tools.
