#!/usr/bin/env bash
#
# setup.sh — the ONLY entry point.
#
# Installs Neovim + dependencies and deploys this repo's config so that
# running `vim` or `nvim` afterwards gives you a fully configured IDE.
#
# Safe to re-run (idempotent). Works on Linux, macOS, and WSL.
#
#   ./setup.sh            # full install
#   ./setup.sh --no-deps  # skip system package install (config only)
#   ./setup.sh --help     # show help
#
set -euo pipefail

# --- resolve repo dir (works regardless of where it's called from) --------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_DIR

# --- load helpers ---------------------------------------------------------
# shellcheck source=install/detect.sh
source "$REPO_DIR/install/detect.sh"
# shellcheck source=install/packages.sh
source "$REPO_DIR/install/packages.sh"
# shellcheck source=install/neovim.sh
source "$REPO_DIR/install/neovim.sh"
# shellcheck source=install/link.sh
source "$REPO_DIR/install/link.sh"
# shellcheck source=install/shell.sh
source "$REPO_DIR/install/shell.sh"
# shellcheck source=install/tree-sitter.sh
source "$REPO_DIR/install/tree-sitter.sh"
# shellcheck source=install/lazygit.sh
source "$REPO_DIR/install/lazygit.sh"

# --- args -----------------------------------------------------------------
DO_DEPS=1
export DO_DEPS
for arg in "$@"; do
  case "$arg" in
    --no-deps) DO_DEPS=0; export DO_DEPS ;;
    -h|--help)
      sed -n '3,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) warn "Unknown argument: $arg" ;;
  esac
done

# --- bootstrap plugins + LSP servers headlessly ---------------------------
repair_treesitter_plugins() {
  local lazy="$HOME/.local/share/nvim/lazy"
  [ -d "$lazy" ] || return 0

  if [ -f "$lazy/nvim-treesitter-textobjects/lua/nvim-treesitter-textobjects.lua" ] \
     && [ ! -f "$lazy/nvim-treesitter-textobjects/lua/nvim-treesitter-textobjects/init.lua" ]; then
    warn "Removing outdated nvim-treesitter-textobjects (master branch)"
    rm -rf "$lazy/nvim-treesitter-textobjects"
  fi

  if [ -d "$lazy/nvim-treesitter/lua/nvim-treesitter/configs" ]; then
    warn "Removing outdated nvim-treesitter (master branch)"
    rm -rf "$lazy/nvim-treesitter"
  fi
}

bootstrap_nvim() {
  log "Bootstrapping plugins and language servers (headless)"
  export PATH="$HOME/.local/bin:$PATH"

  repair_treesitter_plugins

  if nvim --headless "+Lazy! sync" +qa 2>&1 | sed 's/^/    /'; then
    ok "Plugins synced"
  else
    warn "Plugin sync reported issues (often fine on first run)."
  fi

  info "Run :MasonInstallAll inside nvim once to install language servers."
}

main() {
  printf "\n${C_BOLD}nvim-dev setup${C_RESET}\n"
  printf "Repo: %s\n\n" "$REPO_DIR"

  detect_os
  detect_pkg_mgr
  detect_sudo
  detect_ubuntu

  log "Environment"
  info "OS:              $OS"
  info "Package manager: $PKG_MGR"
  info "Privilege:       ${SUDO:-(root/none)}"
  if [ -n "${UBUNTU_VERSION:-}" ]; then
    info "Ubuntu:          ${UBUNTU_VERSION} (${UBUNTU_CODENAME})"
  fi

  if [ "$OS" = "unknown" ]; then
    warn "Unrecognized OS. Proceeding, but you may need to install deps manually."
  fi

  if [ "$DO_DEPS" -eq 1 ]; then
    install_deps
    install_neovim
  else
    warn "--no-deps: skipping system package + Neovim install"
  fi

  install_tree_sitter || warn "tree-sitter unavailable — nvim works without treesitter parsers."
  install_lazygit || warn "lazygit unavailable — use gitsigns or terminal git until installed."

  link_config
  configure_shell

  export PATH="$HOME/.local/bin:$PATH"
  hash -r 2>/dev/null || true
  if have nvim; then
    if tree_sitter_version_ok 2>/dev/null; then
      log "Installing core treesitter parsers (headless)"
      if nvim --headless "+TSInstall! vim" "+TSInstall! vimdoc" "+TSInstall python lua bash json" +qa 2>&1 | sed 's/^/    /'; then
        ok "Core treesitter parsers requested"
      else
        warn "Some parser installs failed — they install on demand when you open a file."
      fi
    else
      info "Skipping treesitter parser install (no working tree-sitter CLI on this host)."
    fi
    bootstrap_nvim
  else
    err "nvim not found on PATH; skipping bootstrap. Re-run after fixing PATH."
  fi

  printf "\n${C_GREEN}${C_BOLD}Done!${C_RESET}\n"
  printf "Open a new terminal (or run 'source ~/.bashrc'), then type: ${C_BOLD}vim${C_RESET}\n"
  printf "New here? Read the docs: ${C_BOLD}docs/README.md${C_RESET}\n\n"
}

main "$@"
