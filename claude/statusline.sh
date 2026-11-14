#!/usr/bin/env bash
# Claude Code status line wrapper: runs ccstatusline with the newest nvm-installed Node.
# Claude Code runs this in a non-interactive shell where nvm isn't loaded, so `node`
# is usually not on PATH.
set -uo pipefail
# Prefer the newest nvm Node that actually has ccstatusline installed (a freshly
# installed Node has no global packages yet); fall back to a node on PATH.
rel=lib/node_modules/ccstatusline/dist/ccstatusline.js
for d in $(ls -d "$HOME"/.nvm/versions/node/*/ 2>/dev/null | sort -rV); do
  if [ -x "$d/bin/node" ] && [ -f "$d/$rel" ]; then exec "$d/bin/node" "$d/$rel"; fi
done
node=$(command -v node 2>/dev/null || true)
if [ -z "$node" ] && ! ls "$HOME"/.nvm/versions/node/*/bin/node >/dev/null 2>&1; then
  echo "statusline: node not found (run bootstrap/deps.sh)"; exit 0
fi
if [ -n "$node" ] && [ -f "$(dirname "$(dirname "$node")")/$rel" ]; then exec "$node" "$(dirname "$(dirname "$node")")/$rel"; fi
echo "statusline: ccstatusline not installed (npm i -g ccstatusline)"
