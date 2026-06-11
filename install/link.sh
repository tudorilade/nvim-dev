#!/usr/bin/env bash
# link.sh — symlink this repo's nvim/ config into ~/.config/nvim,
# backing up any pre-existing config first.

link_config() {
  log "Linking Neovim config"

  local src="$REPO_DIR/nvim"
  local dst="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

  if [ ! -d "$src" ]; then
    err "Config source not found: $src"
    return 1
  fi

  mkdir -p "$(dirname "$dst")"

  # If the destination is already the correct symlink, we're done.
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "Config already linked ($dst -> $src)"
    return 0
  fi

  # Back up an existing real directory or wrong symlink.
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"
    warn "Existing config moved to $backup"
  fi

  ln -s "$src" "$dst"
  ok "Linked $dst -> $src"

  # Also back up stale plugin/state dirs only if they look incompatible.
  # (We leave data/state alone normally so plugins persist across re-runs.)
}
