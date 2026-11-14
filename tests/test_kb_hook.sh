#!/usr/bin/env bash
# Tests claude/hooks/kb_hook.py track/stop logic. Run: bash tests/test_kb_hook.sh
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$REPO/claude/hooks/kb_hook.py"
fail=0
check() { if eval "$2"; then echo "ok   - $1"; else echo "FAIL - $1"; fail=1; fi; }
H=$(mktemp -d); trap 'rm -rf "$H"' EXIT
mkdir -p "$H/real-kb" "$H/proj" && ln -s "$H/real-kb" "$H/kb"
run() { HOME="$H" python3 "$HOOK" "$1"; }

# code edit with no kb edit -> stop blocks
printf '{"session_id":"s1","tool_input":{"file_path":"%s/proj/a.py"}}' "$H" | run track
out=$(printf '{"session_id":"s1"}' | run stop)
check "blocks when code edited and kb not" '[[ "$out" == *block* ]]'

# kb edited through its symlink path (~/kb/...) -> no block
printf '{"session_id":"s2","tool_input":{"file_path":"%s/proj/a.py"}}' "$H" | run track
printf '{"session_id":"s2","tool_input":{"file_path":"%s/kb/index.md"}}' "$H" | run track
out=$(printf '{"session_id":"s2"}' | run stop)
check "kb edit via symlink path counts" '[ -z "$out" ]'

# kb edited through its real path (~/.code/kb/main/...) -> no block
printf '{"session_id":"s3","tool_input":{"file_path":"%s/proj/a.py"}}' "$H" | run track
printf '{"session_id":"s3","tool_input":{"file_path":"%s/real-kb/index.md"}}' "$H" | run track
out=$(printf '{"session_id":"s3"}' | run stop)
check "kb edit via real path counts" '[ -z "$out" ]'
exit $fail
