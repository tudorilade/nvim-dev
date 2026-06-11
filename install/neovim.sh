#!/usr/bin/env bash
# neovim.sh — ensure a modern Neovim (>= 0.10) is installed.
# Strategy: try the package manager; if the version is too old or missing,
# fall back to the official release tarball (Linux) / AppImage.

NVIM_MIN_MAJOR=0
NVIM_MIN_MINOR=11

nvim_version_ok() {
  have nvim || return 1
  local v major minor
  v="$(nvim --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
  [ -z "$v" ] && return 1
  major="${v%%.*}"
  minor="$(echo "$v" | cut -d. -f2)"
  if [ "$major" -gt "$NVIM_MIN_MAJOR" ]; then return 0; fi
  if [ "$major" -eq "$NVIM_MIN_MAJOR" ] && [ "$minor" -ge "$NVIM_MIN_MINOR" ]; then return 0; fi
  return 1
}

install_nvim_pkg() {
  case "$PKG_MGR" in
    brew)   brew install neovim ;;
    apt)    $SUDO apt-get install -y neovim || true ;;
    dnf)    $SUDO dnf install -y neovim || true ;;
    pacman) $SUDO pacman -S --noconfirm --needed neovim || true ;;
    zypper) $SUDO zypper --non-interactive install neovim || true ;;
  esac
}

install_nvim_release() {
  # Installs the official prebuilt Neovim into ~/.local/nvim and symlinks the bin.
  local arch tarball url tmp dest
  arch="$(uname -m)"
  dest="$HOME/.local/nvim"

  case "$(uname -s)" in
    Linux)
      case "$arch" in
        x86_64|amd64) tarball="nvim-linux-x86_64.tar.gz" ;;
        aarch64|arm64) tarball="nvim-linux-arm64.tar.gz" ;;
        *) warn "Unsupported arch '$arch' for prebuilt Neovim."; return 1 ;;
      esac
      ;;
    Darwin)
      case "$arch" in
        arm64) tarball="nvim-macos-arm64.tar.gz" ;;
        x86_64) tarball="nvim-macos-x86_64.tar.gz" ;;
        *) warn "Unsupported arch '$arch' for prebuilt Neovim."; return 1 ;;
      esac
      ;;
    *) return 1 ;;
  esac

  url="https://github.com/neovim/neovim/releases/latest/download/${tarball}"
  tmp="$(mktemp -d)"
  log "Downloading prebuilt Neovim: $url"
  if ! curl -fsSL "$url" -o "$tmp/$tarball"; then
    err "Failed to download Neovim release."
    rm -rf "$tmp"; return 1
  fi

  rm -rf "$dest"
  mkdir -p "$dest"
  tar -xzf "$tmp/$tarball" -C "$tmp"
  local extracted
  extracted="$(find "$tmp" -maxdepth 1 -type d -name 'nvim-*' | head -n1)"
  if [ -z "$extracted" ]; then
    err "Could not find extracted Neovim directory."
    rm -rf "$tmp"; return 1
  fi
  cp -a "$extracted/." "$dest/"
  rm -rf "$tmp"

  mkdir -p "$HOME/.local/bin"
  ln -sf "$dest/bin/nvim" "$HOME/.local/bin/nvim"
  ok "Installed Neovim to $dest (symlinked to ~/.local/bin/nvim)"
}

install_neovim() {
  log "Ensuring Neovim >= ${NVIM_MIN_MAJOR}.${NVIM_MIN_MINOR}"

  if nvim_version_ok; then
    ok "Neovim already up to date ($(nvim --version | head -n1))"
    return 0
  fi

  install_nvim_pkg
  hash -r 2>/dev/null || true

  if nvim_version_ok; then
    ok "Neovim installed via package manager ($(nvim --version | head -n1))"
    return 0
  fi

  warn "Package manager Neovim missing or too old; using official release."
  # ensure ~/.local/bin is ahead on PATH for this session
  export PATH="$HOME/.local/bin:$PATH"
  install_nvim_release || return 1
  hash -r 2>/dev/null || true

  if nvim_version_ok; then
    ok "Neovim ready ($(nvim --version | head -n1))"
  else
    err "Neovim still not at required version. Check your PATH includes ~/.local/bin."
    return 1
  fi
}
