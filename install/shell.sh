#!/usr/bin/env bash
# shell.sh — add `alias vim=nvim`, set EDITOR, and ensure ~/.local/bin is on PATH.
# Edits are idempotent and clearly marked with a managed block.

BLOCK_BEGIN="# >>> nvim-dev setup >>>"
BLOCK_END="# <<< nvim-dev setup <<<"

managed_block() {
  cat <<'EOF'
# >>> nvim-dev setup >>>
# Added by nvim-dev setup.sh — safe to remove this whole block.
export PATH="$HOME/.local/bin:$PATH"
alias vim='nvim'
alias vi='nvim'
export EDITOR='nvim'
export VISUAL='nvim'
# <<< nvim-dev setup <<<
EOF
}

write_block_to() {
  local rc="$1"
  [ -z "$rc" ] && return 0
  touch "$rc"

  if grep -qF "$BLOCK_BEGIN" "$rc" 2>/dev/null; then
    # Replace the existing managed block.
    local tmp
    tmp="$(mktemp)"
    awk -v b="$BLOCK_BEGIN" -v e="$BLOCK_END" '
      $0==b {skip=1}
      skip==0 {print}
      $0==e {skip=0}
    ' "$rc" > "$tmp"
    managed_block >> "$tmp"
    mv "$tmp" "$rc"
    ok "Updated shell block in $rc"
  else
    {
      echo ""
      managed_block
    } >> "$rc"
    ok "Added shell block to $rc"
  fi
}

configure_shell() {
  log "Configuring shell (alias vim=nvim, EDITOR, PATH)"

  # Always do bash; add zsh too if the user has a zshrc or zsh as login shell.
  write_block_to "$HOME/.bashrc"

  if [ -f "$HOME/.zshrc" ] || echo "${SHELL:-}" | grep -q zsh; then
    write_block_to "$HOME/.zshrc"
  fi

  # macOS Terminal sources .bash_profile for login shells; chain it to .bashrc.
  if [ "$OS" = "macos" ]; then
    if [ ! -f "$HOME/.bash_profile" ] || ! grep -q "\.bashrc" "$HOME/.bash_profile" 2>/dev/null; then
      echo '[ -r ~/.bashrc ] && . ~/.bashrc' >> "$HOME/.bash_profile"
      ok "Chained ~/.bash_profile -> ~/.bashrc"
    fi
  fi

  info "Open a new shell (or 'source ~/.bashrc') to pick up the alias."
}
