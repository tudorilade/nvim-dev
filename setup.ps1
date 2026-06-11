<#
.SYNOPSIS
  Secondary Windows helper for the nvim-dev setup.

.DESCRIPTION
  The supported entry point is setup.sh (Linux/macOS/WSL). This PowerShell
  script is a thin convenience for native Windows users: it installs Neovim and
  the required tools via winget/scoop/choco when possible, then symlinks the
  nvim/ config into your Windows Neovim config location.

  Run from an ELEVATED PowerShell prompt for the symlink step:
      ./setup.ps1
#>

$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Info($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "  + $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "  ! $msg" -ForegroundColor Yellow }

function Have($name) { $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }

Info "nvim-dev setup (Windows helper)"
Info "Repo: $RepoDir"

# --- install dependencies -------------------------------------------------
function Install-Deps {
    $pkgsWinget = @(
        "Neovim.Neovim", "BurntSushi.ripgrep.MSVC", "sharkdp.fd",
        "Git.Git", "OpenJS.NodeJS.LTS", "Python.Python.3.12"
    )
    if (Have winget) {
        Info "Installing dependencies via winget"
        foreach ($p in $pkgsWinget) {
            try { winget install --silent --accept-source-agreements --accept-package-agreements -e --id $p }
            catch { Warn "winget failed for $p (may already be installed)" }
        }
        Ok "winget dependencies processed"
        return
    }
    if (Have scoop) {
        Info "Installing dependencies via scoop"
        scoop install neovim ripgrep fd git nodejs python
        Ok "scoop dependencies processed"
        return
    }
    if (Have choco) {
        Info "Installing dependencies via choco"
        choco install -y neovim ripgrep fd git nodejs python
        Ok "choco dependencies processed"
        return
    }
    Warn "No winget/scoop/choco found. Install manually: neovim ripgrep fd git nodejs python"
}

# --- link config ----------------------------------------------------------
function Link-Config {
    $src = Join-Path $RepoDir "nvim"
    $dst = Join-Path $env:LOCALAPPDATA "nvim"

    if (-not (Test-Path $src)) { throw "Config source not found: $src" }

    if (Test-Path $dst) {
        $backup = "$dst.backup.$(Get-Date -Format yyyyMMddHHmmss)"
        Move-Item $dst $backup
        Warn "Existing config moved to $backup"
    }

    New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
    Ok "Linked $dst -> $src"
}

# --- bootstrap ------------------------------------------------------------
function Bootstrap {
    if (Have nvim) {
        Info "Bootstrapping plugins (headless)"
        nvim --headless "+Lazy! sync" +qa
        nvim --headless "+MasonInstallAll" +qa
        Ok "Bootstrap complete"
    } else {
        Warn "nvim not on PATH yet; open a new terminal and run nvim to finish."
    }
}

Install-Deps
Link-Config
Bootstrap

Write-Host ""
Write-Host "Done! Open a new terminal and run: nvim" -ForegroundColor Green
Write-Host "Docs: docs/README.md" -ForegroundColor Green
