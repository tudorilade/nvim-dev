#!/usr/bin/env bash
# lazygit.sh — install the lazygit TUI binary to ~/.local/bin.
# Used by <leader>gg, <leader>gf, and <leader>tg in nvim.
#
# Release asset names are versioned, e.g. lazygit_0.62.2_linux_x86_64.tar.gz
# (not lazygit_Linux_x86_64.tar.gz).

lazygit_release_url() {
  local os arch api json tag ver asset
  case "$(uname -s)" in
    Linux)  os="linux" ;;
    Darwin) os="darwin" ;;
    *) return 1 ;;
  esac
  case "$(uname -m)" in
    x86_64|amd64) arch="x86_64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) return 1 ;;
  esac

  api="https://api.github.com/repos/jesseduffield/lazygit/releases/latest"
  json="$(curl -fsSL "$api")" || return 1
  tag="$(printf '%s' "$json" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": "//;s/".*//')"
  [ -n "$tag" ] || return 1
  ver="${tag#v}"
  asset="lazygit_${ver}_${os}_${arch}.tar.gz"
  printf 'https://github.com/jesseduffield/lazygit/releases/download/%s/%s\n' "$tag" "$asset"
}

install_lazygit_release() {
  local url tmp bin
  mkdir -p "$HOME/.local/bin"

  url="$(lazygit_release_url)" || {
    err "Could not resolve lazygit release URL for this OS/arch."
    return 1
  }

  tmp="$(mktemp -d)"
  log "Downloading lazygit: $url"
  if ! curl -fsSL "$url" -o "$tmp/lazygit.tar.gz"; then
    err "Failed to download lazygit (404 or network — check GitHub access)."
    rm -rf "$tmp"
    return 1
  fi

  if ! tar -xzf "$tmp/lazygit.tar.gz" -C "$tmp"; then
    err "Failed to extract lazygit."
    rm -rf "$tmp"
    return 1
  fi

  bin="$(find "$tmp" -type f -name lazygit 2>/dev/null | head -n1)"
  if [ -z "$bin" ]; then
    err "lazygit binary not found in archive."
    rm -rf "$tmp"
    return 1
  fi

  install -m 0755 "$bin" "$HOME/.local/bin/lazygit"
  rm -rf "$tmp"
  ok "Installed lazygit to ~/.local/bin/lazygit"
}

install_lazygit() {
  export PATH="$HOME/.local/bin:$PATH"

  if have lazygit && lazygit --version >/dev/null 2>&1; then
    ok "lazygit already available ($(lazygit --version 2>/dev/null | head -n1))"
    return 0
  fi

  if [ "${DO_DEPS:-1}" -eq 1 ] && [ "${PKG_MGR:-none}" = "apt" ]; then
    if apt-cache show lazygit >/dev/null 2>&1; then
      log "Installing lazygit via apt"
      ${SUDO:+$SUDO }apt-get install -y lazygit 2>/dev/null || true
      hash -r 2>/dev/null || true
      if have lazygit && lazygit --version >/dev/null 2>&1; then
        ok "lazygit installed via apt"
        return 0
      fi
    fi
  fi

  if [ "${PKG_MGR:-none}" = "brew" ]; then
    brew install lazygit 2>/dev/null || true
    hash -r 2>/dev/null || true
    if have lazygit; then
      ok "lazygit installed via brew"
      return 0
    fi
  fi

  install_lazygit_release || return 1
  hash -r 2>/dev/null || true

  if have lazygit && lazygit --version >/dev/null 2>&1; then
    ok "lazygit ready ($(lazygit --version 2>/dev/null | head -n1))"
  else
    err "lazygit install failed"
    return 1
  fi
}
