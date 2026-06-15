#!/usr/bin/env bash
# tree-sitter.sh — ensure tree-sitter CLI (>= 0.26.1) is on PATH.
# nvim-treesitter main compiles parsers locally and requires this binary.
# Falls back to a GitHub release download into ~/.local/bin (no root needed).

TS_MIN_MAJOR=0
TS_MIN_MINOR=26
TS_MIN_PATCH=1

tree_sitter_version_ok() {
  have tree-sitter || return 1
  local v major minor patch
  v="$(tree-sitter --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
  [ -z "$v" ] && return 1
  major="${v%%.*}"
  minor="$(echo "$v" | cut -d. -f2)"
  patch="$(echo "$v" | cut -d. -f3)"
  if [ "$major" -gt "$TS_MIN_MAJOR" ]; then return 0; fi
  if [ "$major" -eq "$TS_MIN_MAJOR" ] && [ "$minor" -gt "$TS_MIN_MINOR" ]; then return 0; fi
  if [ "$major" -eq "$TS_MIN_MAJOR" ] && [ "$minor" -eq "$TS_MIN_MINOR" ] && [ "${patch:-0}" -ge "$TS_MIN_PATCH" ]; then
    return 0
  fi
  return 1
}

install_tree_sitter_release() {
  local arch asset tmp dest
  dest="$HOME/.local/bin/tree-sitter"
  mkdir -p "$HOME/.local/bin"

  case "$(uname -s)" in
    Linux)
      case "$(uname -m)" in
        x86_64|amd64) asset="tree-sitter-linux-x64.gz" ;;
        aarch64|arm64) asset="tree-sitter-linux-arm64.gz" ;;
        *) warn "Unsupported Linux arch '$(uname -m)' for tree-sitter release."; return 1 ;;
      esac
      ;;
    Darwin)
      case "$(uname -m)" in
        arm64) asset="tree-sitter-macos-arm64.gz" ;;
        x86_64) asset="tree-sitter-macos-x64.gz" ;;
        *) warn "Unsupported macOS arch '$(uname -m)' for tree-sitter release."; return 1 ;;
      esac
      ;;
    *)
      warn "Unsupported OS for tree-sitter release download."
      return 1
      ;;
  esac

  local url="https://github.com/tree-sitter/tree-sitter/releases/latest/download/${asset}"
  tmp="$(mktemp)"
  log "Downloading tree-sitter CLI: $url"
  if ! curl -fsSL "$url" -o "$tmp"; then
    err "Failed to download tree-sitter."
    rm -f "$tmp"
    return 1
  fi

  if ! gunzip -c "$tmp" > "$dest" 2>/dev/null; then
    err "Failed to extract tree-sitter binary."
    rm -f "$tmp" "$dest"
    return 1
  fi
  rm -f "$tmp"
  chmod +x "$dest"
  ok "Installed tree-sitter to $dest"
}

install_tree_sitter() {
  export PATH="$HOME/.local/bin:$PATH"

  if tree_sitter_version_ok; then
    ok "tree-sitter already available ($(tree-sitter --version 2>/dev/null | head -n1))"
    return 0
  fi

  # Try package manager when we have one (may be skipped with --no-deps).
  if [ "${DO_DEPS:-1}" -eq 1 ] && [ "${PKG_MGR:-none}" != "none" ]; then
    case "$PKG_MGR" in
      apt)    ${SUDO:+$SUDO }apt-get install -y tree-sitter 2>/dev/null || true ;;
      brew)   brew install tree-sitter 2>/dev/null || true ;;
      pacman) ${SUDO:+$SUDO }pacman -S --noconfirm --needed tree-sitter 2>/dev/null || true ;;
    esac
    hash -r 2>/dev/null || true
    if tree_sitter_version_ok; then
      ok "tree-sitter installed via package manager"
      return 0
    fi
  fi

  warn "tree-sitter not found; downloading prebuilt binary to ~/.local/bin"
  install_tree_sitter_release || return 1
  hash -r 2>/dev/null || true

  if tree_sitter_version_ok; then
    ok "tree-sitter ready ($(tree-sitter --version 2>/dev/null | head -n1))"
  else
    err "tree-sitter still missing. Parsers will not compile until it is on PATH."
    return 1
  fi
}
