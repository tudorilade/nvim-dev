#!/usr/bin/env bash
# packages.sh — install system dependencies via the detected package manager.
# Expects OS, PKG_MGR, SUDO and the logging helpers from detect.sh.

pkg_update() {
  case "$PKG_MGR" in
    apt)    $SUDO apt-get update -y ;;
    dnf)    $SUDO dnf -y makecache || true ;;
    pacman) $SUDO pacman -Sy --noconfirm ;;
    zypper) $SUDO zypper --non-interactive refresh || true ;;
    brew)   brew update || true ;;
  esac
}

pkg_install() {
  # $@ = list of package names (already mapped to this manager)
  [ "$#" -eq 0 ] && return 0
  case "$PKG_MGR" in
    apt)    $SUDO apt-get install -y "$@" ;;
    dnf)    $SUDO dnf install -y "$@" ;;
    pacman) $SUDO pacman -S --noconfirm --needed "$@" ;;
    zypper) $SUDO zypper --non-interactive install "$@" ;;
    brew)   brew install "$@" ;;
  esac
}

# Map a logical dependency to the right package name per manager, then install.
install_deps() {
  log "Installing system dependencies"

  if [ "$PKG_MGR" = "none" ]; then
    err "No supported package manager found (apt/dnf/pacman/zypper/brew)."
    err "Please install these manually: git ripgrep fd curl unzip gcc/clang make node python3"
    return 1
  fi

  pkg_update

  # Common logical deps. Names differ across managers, so map them.
  local pkgs=()
  case "$PKG_MGR" in
    apt)
      pkgs=(git curl wget unzip tar ripgrep fd-find build-essential
            python3 python3-pip python3-venv nodejs npm xclip)
      ;;
    dnf)
      pkgs=(git curl wget unzip tar ripgrep fd-find gcc gcc-c++ make
            python3 python3-pip nodejs npm xclip)
      ;;
    pacman)
      pkgs=(git curl wget unzip tar ripgrep fd base-devel
            python python-pip nodejs npm xclip)
      ;;
    zypper)
      pkgs=(git curl wget unzip tar ripgrep fd gcc gcc-c++ make
            python3 python3-pip nodejs npm xclip)
      ;;
    brew)
      pkgs=(git curl wget unzip ripgrep fd make node python tree-sitter)
      ;;
  esac

  pkg_install "${pkgs[@]}" || warn "Some packages failed to install; continuing."

  # On Debian/Ubuntu, fd is installed as 'fdfind'. Make a user-local 'fd' shim.
  if [ "$PKG_MGR" = "apt" ] && have fdfind && ! have fd; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    ok "Linked fdfind -> ~/.local/bin/fd"
  fi

  ok "Dependencies installed"
}
