#!/usr/bin/env bash
# Copy files that install.sh *copies* (not links) back from $HOME into the repo,
# e.g. after changing settings with /config or the ccstatusline menu. Review with git diff.
set -euo pipefail
REPO="${REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
cp "$HOME/.claude/settings.json"                 "$REPO/claude/settings.json"
cp "$HOME/.config/ccstatusline/settings.json"     "$REPO/ccstatusline/settings.json"
git -C "$REPO" status --short -- claude/settings.json ccstatusline/settings.json 2>/dev/null || true
