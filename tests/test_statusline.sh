#!/usr/bin/env bash
# Tests for claude/statusline.sh. Run: bash tests/test_statusline.sh
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
SL="$REPO/claude/statusline.sh"
fail=0
check() { if eval "$2"; then echo "ok   - $1"; else echo "FAIL - $1"; fail=1; fi; }

json='{"session_id":"t","transcript_path":"'"$REPO"'/tests/fixtures/transcript.jsonl","cwd":"/tmp","model":{"id":"claude-opus-5-5","display_name":"Opus 5.5"},"workspace":{"current_dir":"/tmp"},"cost":{"total_cost_usd":0.5}}'

# (a) renders with the real nvm install
out=$(printf '%s' "$json" | bash "$SL" 2>&1); rc=$?
check "renders model + token total (rc=$rc)" '[ $rc -eq 0 ] && [[ "$out" == *Model:* ]] && [[ "$out" == *Total:* ]]'

# (b) no node available -> fallback line, exit 0
tmp=$(mktemp -d)
out=$(printf '%s' "$json" | HOME="$tmp" PATH=/usr/bin:/bin bash "$SL" 2>&1); rc=$?
check "fallback when node missing (rc=$rc)" '[ $rc -eq 0 ] && [[ "$out" == *"statusline: node not found"* ]]'
rm -rf "$tmp"

# (c) newer node without ccstatusline must not shadow an older node that has it
tmp=$(mktemp -d)
for v in v20.0.0 v22.0.0; do mkdir -p "$tmp/.nvm/versions/node/$v/bin"; printf '#!/bin/sh\necho "node-%s $@"\n' "$v" > "$tmp/.nvm/versions/node/$v/bin/node"; chmod +x "$tmp/.nvm/versions/node/$v/bin/node"; done
mkdir -p "$tmp/.nvm/versions/node/v20.0.0/lib/node_modules/ccstatusline/dist" && touch "$tmp/.nvm/versions/node/v20.0.0/lib/node_modules/ccstatusline/dist/ccstatusline.js"
out=$(printf '{}' | HOME="$tmp" PATH=/usr/bin:/bin bash "$SL" 2>&1)
check "uses newest node that has ccstatusline (got: $out)" '[[ "$out" == node-v20.0.0* ]]'
rm -rf "$tmp"
exit $fail
