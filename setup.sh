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

# --- args -----------------------------------------------------------------
DO_DEPS=1
for arg in "$@"; do
  case "$arg" in
    --no-deps) DO_DEPS=0 ;;
    -h|--help)
      sed -n '3,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) warn "Unknown argument: $arg" ;;
  esac
done

# --- bootstrap plugins + LSP servers headlessly ---------------------------
bootstrap_nvim() {
  log "Bootstrapping plugins and language servers (headless)"
  export PATH="$HOME/.local/bin:$PATH"

  # 1) Install/sync plugins via lazy.nvim.
  if nvim --headless "+Lazy! sync" +qa 2>&1 | sed 's/^/    /'; then
    ok "Plugins synced"
  else
    warn "Plugin sync reported issues (often fine on first run)."
  fi

  # 2) Pre-install the language servers / tools via Mason, if available.
  #    MasonInstallAll is provided by our config (see plugins/lsp.lua).
  if nvim --headless "+MasonInstallAll" +qa 2>&1 | sed 's/^/    /'; then
    ok "Language servers requested via Mason"
  else
    info "Mason tools will finish installing on first interactive launch."
  fi
}

main() {
  printf "\n${C_BOLD}nvim-dev setup${C_RESET}\n"
  printf "Repo: %s\n\n" "$REPO_DIR"

  detect_os
  detect_pkg_mgr
  detect_sudo

  log "Environment"
  info "OS:              $OS"
  info "Package manager: $PKG_MGR"
  info "Privilege:       ${SUDO:-(root/none)}"

  if [ "$OS" = "unknown" ]; then
    warn "Unrecognized OS. Proceeding, but you may need to install deps manually."
  fi

  if [ "$DO_DEPS" -eq 1 ]; then
    install_deps
    install_neovim
  else
    warn "--no-deps: skipping system package + Neovim install"
  fi

  # Always ensure tree-sitter CLI (user-local download; needed for nvim-treesitter main).
  install_tree_sitter || warn "tree-sitter missing — run ./setup.sh again or install manually."

  link_config
  configure_shell

  # Make sure nvim is reachable for the bootstrap step.
  export PATH="$HOME/.local/bin:$PATH"
  hash -r 2>/dev/null || true
  if have nvim; then
    export PATH="$HOME/.local/bin:$PATH"
    if have tree-sitter; then
      log "Updating treesitter parsers (headless)"
      if nvim --headless "+TSUpdate" +qa 2>&1 | sed 's/^/    /'; then
        ok "Treesitter parsers updated"
      else
        warn "TSUpdate reported issues (may finish on first interactive launch)."
      fi
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
