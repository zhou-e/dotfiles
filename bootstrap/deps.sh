#!/usr/bin/env bash
# Install the tools this setup depends on, into $HOME (no sudo). Skips anything already present.
# Linux x86_64 only. See README.md "Software" for the full list.
set -euo pipefail
BIN="$HOME/.local/bin"; mkdir -p "$BIN"
export PATH="$BIN:$PATH"   # installers (e.g. beads) check that their binary is on PATH
have() { command -v "$1" >/dev/null 2>&1 || [ -x "$BIN/$1" ]; }
tmpd=$(mktemp -d); trap 'rm -rf "$tmpd"' EXIT

# nvm + Node LTS + ccstatusline (status line bar)
NVM_VERSION=v0.40.3
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  echo "== installing nvm $NVM_VERSION"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" -o "$tmpd/nvm.sh"
  PROFILE=/dev/null bash "$tmpd/nvm.sh"   # don't edit ~/.bashrc; shell/bashrc.d/dotfiles.sh loads nvm
fi
set +u; . "$NVM_DIR/nvm.sh"
nvm ls --no-colors lts/* >/dev/null 2>&1 || { echo "== installing Node LTS"; nvm install --lts; }
nvm use --lts >/dev/null
[ -f "$(npm root -g)/ccstatusline/dist/ccstatusline.js" ] || { echo "== installing ccstatusline"; npm i -g ccstatusline; }
set -u

# GitHub CLI (release tarball)
if ! have gh; then
  echo "== installing gh"
  url=$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest \
        | python3 -c "import json,sys;print(next(a['browser_download_url'] for a in json.load(sys.stdin)['assets'] if a['name'].endswith('linux_amd64.tar.gz')))")
  curl -fsSL "$url" -o "$tmpd/gh.tgz"
  tar -xzf "$tmpd/gh.tgz" -C "$tmpd"
  install -m 755 "$tmpd"/gh_*_linux_amd64/bin/gh "$BIN/gh"
fi

# beads (bd): task tracker used by the Claude workflow
if ! have bd; then
  echo "== installing beads (bd)"
  curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh -o "$tmpd/bd.sh"
  bash "$tmpd/bd.sh"
fi

# Not installed here: print what's missing.
have claude || echo "!! Claude Code missing:  curl -fsSL https://claude.ai/install.sh | bash"
have aws    || echo "!! AWS CLI missing:      see README.md (installs to ~/.local/aws-cli, no sudo)"
have tmux   || echo "!! tmux missing:         sudo apt install tmux"
have python3 || echo "!! python3 missing:     sudo apt install python3   (kb hook needs it)"
echo "deps done."
