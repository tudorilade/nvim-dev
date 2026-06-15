#!/usr/bin/env bash
# tree-sitter.sh — ensure tree-sitter CLI is on PATH.
# nvim-treesitter main compiles parsers locally and requires this binary.

tree_sitter_bin() {
  if [ -x "$HOME/.local/bin/tree-sitter" ]; then
    printf '%s\n' "$HOME/.local/bin/tree-sitter"
    return 0
  fi
  command -v tree-sitter 2>/dev/null || return 1
}

tree_sitter_version_ok() {
  local bin
  bin="$(tree_sitter_bin)" || return 1
  # Binary must run; strict semver parsing fails on some release builds.
  "$bin" --version >/dev/null 2>&1 || "$bin" version >/dev/null 2>&1 || return 1
  return 0
}

install_tree_sitter_release() {
  local asset tmp dest
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
    err "Failed to download tree-sitter (GitHub may be blocked — install manually)."
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

  if ! file "$dest" 2>/dev/null | grep -qE 'ELF|Mach-O'; then
    err "Downloaded file is not a valid binary (proxy/mirror may have returned HTML)."
    rm -f "$dest"
    return 1
  fi

  ok "Installed tree-sitter to $dest"
}

install_tree_sitter() {
  export PATH="$HOME/.local/bin:$PATH"

  # Mason's tree-sitter CLI is often the wrong version and breaks parser builds.
  local mason_ts="$HOME/.local/share/nvim/mason/bin/tree-sitter"
  if [ -e "$mason_ts" ]; then
    warn "Removing Mason tree-sitter (wrong version): $mason_ts"
    rm -f "$mason_ts"
  fi

  if tree_sitter_version_ok; then
    ok "tree-sitter already available ($("$(tree_sitter_bin)" --version 2>/dev/null | head -n1))"
    return 0
  fi

  if [ "${DO_DEPS:-1}" -eq 1 ] && [ "${PKG_MGR:-none}" != "none" ]; then
    case "$PKG_MGR" in
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
    ok "tree-sitter ready ($("$(tree_sitter_bin)" --version 2>/dev/null | head -n1))"
  else
    err "tree-sitter binary installed but does not run — check Bitdefender/proxy blocking GitHub."
    return 1
  fi
}
