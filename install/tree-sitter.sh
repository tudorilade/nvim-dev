#!/usr/bin/env bash
# tree-sitter.sh — ensure tree-sitter CLI is on PATH and actually runs.
#
# Ubuntu pinning (glibc):
#   22.04 jammy  — glibc 2.35: build with cargo OR try old GitHub binaries only
#   24.04 noble  — glibc 2.39: GitHub "latest" prebuilt is OK
#   other/unknown — conservative (same as 22.04)

tree_sitter_bin() {
  if [ -x "$HOME/.local/bin/tree-sitter" ]; then
    printf '%s\n' "$HOME/.local/bin/tree-sitter"
    return 0
  fi
  command -v tree-sitter 2>/dev/null || return 1
}

tree_sitter_runs() {
  local bin="$1"
  local err
  err="$("$bin" --version 2>&1)" && return 0
  if echo "$err" | grep -qE 'GLIBC|cannot open shared object'; then
    warn "tree-sitter binary incompatible with this system libc: ${err%%$'\n'*}"
  fi
  return 1
}

tree_sitter_version_ok() {
  local bin
  bin="$(tree_sitter_bin)" || return 1
  tree_sitter_runs "$bin"
}

remove_broken_tree_sitter() {
  local dest="$HOME/.local/bin/tree-sitter"
  if [ -e "$dest" ] && ! tree_sitter_runs "$dest"; then
    rm -f "$dest"
  fi
}

# Return pinned GitHub release tags to try for this host (space-separated).
tree_sitter_pinned_versions() {
  if ubuntu_at_least 24.04; then
    # Noble+: latest prebuilts target glibc 2.39+
    printf '%s\n' "latest 0.26.9 0.24.7"
  elif [ "${UBUNTU_VERSION:-}" = "22.04" ]; then
    # Jammy: never try "latest" (needs glibc 2.39)
    printf '%s\n' "0.22.6 0.20.8"
  else
    # Unknown Linux / older Ubuntu — conservative pins only
    printf '%s\n' "0.22.6 0.20.8"
  fi
}

tree_sitter_strategy_label() {
  if ubuntu_at_least 24.04; then
    echo "Ubuntu 24.04+ (prebuilt latest OK)"
  elif [ "${UBUNTU_VERSION:-}" = "22.04" ]; then
    echo "Ubuntu 22.04 jammy (cargo build or old prebuilt pins)"
  elif [ -n "${UBUNTU_VERSION:-}" ]; then
    echo "Ubuntu ${UBUNTU_VERSION} (conservative pins)"
  else
    echo "non-Ubuntu / unknown (conservative pins)"
  fi
}

install_tree_sitter_from_url() {
  local url="$1"
  local dest="$HOME/.local/bin/tree-sitter"
  local tmp
  tmp="$(mktemp)"
  log "Downloading tree-sitter CLI: $url"
  if ! curl -fsSL "$url" -o "$tmp"; then
    rm -f "$tmp"
    return 1
  fi
  if ! gunzip -c "$tmp" > "$dest" 2>/dev/null; then
    rm -f "$tmp" "$dest"
    return 1
  fi
  rm -f "$tmp"
  chmod +x "$dest"
  if ! file "$dest" 2>/dev/null | grep -qE 'ELF|Mach-O'; then
    rm -f "$dest"
    return 1
  fi
  tree_sitter_runs "$dest"
}

install_tree_sitter_release() {
  local asset ver url versions
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
      # macOS: try latest first regardless of Ubuntu
      versions="latest 0.26.9 0.24.7 0.22.6"
      ;;
    *)
      warn "Unsupported OS for tree-sitter release download."
      return 1
      ;;
  esac

  if [ "$(uname -s)" = "Linux" ]; then
    versions="$(tree_sitter_pinned_versions)"
  fi

  info "tree-sitter release pins: $versions"

  for ver in $versions; do
    if [ "$ver" = "latest" ]; then
      url="https://github.com/tree-sitter/tree-sitter/releases/latest/download/${asset}"
    else
      url="https://github.com/tree-sitter/tree-sitter/releases/download/v${ver}/${asset}"
    fi
    remove_broken_tree_sitter
    if install_tree_sitter_from_url "$url"; then
      ok "Installed tree-sitter ($ver) to ~/.local/bin/tree-sitter"
      return 0
    fi
  done
  return 1
}

install_rust_for_jammy() {
  # Ubuntu 22.04 has no apt tree-sitter package; cargo build is the reliable path.
  [ "${UBUNTU_VERSION:-}" = "22.04" ] || return 0
  [ "${DO_DEPS:-1}" -eq 1 ] || return 0
  have cargo && return 0
  log "Installing rustc/cargo for Ubuntu 22.04 (build tree-sitter against glibc 2.35)"
  case "$PKG_MGR" in
    apt) ${SUDO:+$SUDO }apt-get install -y cargo rustc build-essential ;;
  esac
  hash -r 2>/dev/null || true
}

install_tree_sitter_cargo() {
  install_rust_for_jammy
  have cargo || return 1
  log "Building tree-sitter CLI with cargo (linked to this machine's libc)"
  if ! cargo install tree-sitter-cli --locked --force --root "$HOME/.local"; then
    warn "cargo install tree-sitter-cli failed"
    return 1
  fi
  hash -r 2>/dev/null || true
  tree_sitter_version_ok
}

install_tree_sitter() {
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
  detect_ubuntu

  info "tree-sitter strategy: $(tree_sitter_strategy_label)"

  local mason_ts="$HOME/.local/share/nvim/mason/bin/tree-sitter"
  if [ -e "$mason_ts" ]; then
    warn "Removing Mason tree-sitter (often wrong version): $mason_ts"
    rm -f "$mason_ts"
  fi

  remove_broken_tree_sitter

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

  # Ubuntu 22.04: prefer cargo (always matches local glibc), then old prebuilts.
  if [ "${UBUNTU_VERSION:-}" = "22.04" ]; then
    if install_tree_sitter_cargo; then
      ok "tree-sitter ready (cargo build on jammy)"
      return 0
    fi
    warn "cargo build failed; trying jammy-safe prebuilt pins"
    if install_tree_sitter_release; then
      return 0
    fi
  else
    if install_tree_sitter_release; then
      return 0
    fi
    if install_tree_sitter_cargo; then
      ok "tree-sitter ready (cargo build)"
      return 0
    fi
  fi

  remove_broken_tree_sitter
  err "tree-sitter CLI unavailable on this system."
  if [ "${UBUNTU_VERSION:-}" = "22.04" ]; then
    info "On Ubuntu 22.04 run: sudo apt install cargo rustc build-essential && cargo install tree-sitter-cli --locked --force --root ~/.local"
  fi
  info "Neovim still works without treesitter parsers."
  return 1
}
