#!/usr/bin/env bash
# detect.sh — OS + package-manager detection helpers.
# Sourced by setup.sh; defines OS, PKG_MGR, and helper functions.

# --- pretty logging -------------------------------------------------------
if [ -t 1 ]; then
  C_RESET="\033[0m"; C_BLUE="\033[34m"; C_GREEN="\033[32m"
  C_YELLOW="\033[33m"; C_RED="\033[31m"; C_BOLD="\033[1m"
else
  C_RESET=""; C_BLUE=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_BOLD=""
fi

log()  { printf "${C_BLUE}${C_BOLD}==>${C_RESET} %s\n" "$*"; }
info() { printf "    %s\n" "$*"; }
ok()   { printf "${C_GREEN}  ✓${C_RESET} %s\n" "$*"; }
warn() { printf "${C_YELLOW}  !${C_RESET} %s\n" "$*"; }
err()  { printf "${C_RED}  ✗${C_RESET} %s\n" "$*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

# --- OS detection ---------------------------------------------------------
detect_os() {
  local uname_s
  uname_s="$(uname -s 2>/dev/null || echo unknown)"
  case "$uname_s" in
    Linux*)
      if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
        OS="wsl"
      else
        OS="linux"
      fi
      ;;
    Darwin*) OS="macos" ;;
    *)       OS="unknown" ;;
  esac
  export OS
}

# --- package manager detection -------------------------------------------
detect_pkg_mgr() {
  if have brew;   then PKG_MGR="brew"
  elif have apt-get; then PKG_MGR="apt"
  elif have dnf;  then PKG_MGR="dnf"
  elif have pacman; then PKG_MGR="pacman"
  elif have zypper; then PKG_MGR="zypper"
  else PKG_MGR="none"
  fi
  export PKG_MGR
}

# sudo wrapper: only use sudo when not root and sudo exists (brew never needs it)
SUDO=""
detect_sudo() {
  if [ "$(id -u)" -ne 0 ] && [ "$PKG_MGR" != "brew" ] && have sudo; then
    SUDO="sudo"
  fi
  export SUDO
}

# --- Ubuntu version (for pinning glibc-sensitive tools like tree-sitter) ----
# Reads /etc/os-release — works without lsb_release (often missing on minimal images).
# Exports: UBUNTU_VERSION (e.g. 22.04), UBUNTU_CODENAME (e.g. jammy), or empty if not Ubuntu.
detect_ubuntu() {
  UBUNTU_VERSION=""
  UBUNTU_CODENAME=""
  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    if [ "${ID:-}" = "ubuntu" ]; then
      UBUNTU_VERSION="${VERSION_ID:-}"
      UBUNTU_CODENAME="${VERSION_CODENAME:-}"
    fi
  fi
  export UBUNTU_VERSION UBUNTU_CODENAME
}

ubuntu_at_least() {
  # True when Ubuntu VERSION_ID >= argument (e.g. 24.04). False if not Ubuntu.
  local want="$1"
  [ -n "${UBUNTU_VERSION:-}" ] || return 1
  awk -v have="$UBUNTU_VERSION" -v want="$want" 'BEGIN { exit !(have+0 >= want+0) }'
}
