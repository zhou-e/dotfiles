#!/usr/bin/env bash
# Proves tests/test_no_secrets.sh catches each kind of leak, using a temp copy of the repo.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
decoys=(
  'email = jane@acme.io'
  'url https://d-1234567890.awsapps.com/start'
  'token ghp_abcdefghijklmnopqrstuvwxyz0123456789'
  'key AKIAABCDEFGHIJKLMNOP'
  'key sk-ant-api03-abcdef'
  'acct 123456789012'
)
for d in "${decoys[@]}"; do
  T=$(mktemp -d); (cd "$REPO" && git ls-files -z | xargs -0 cp --parents -t "$T")
  git -C "$T" init -q; printf '%s\n' "$d" > "$T/decoy.txt"; git -C "$T" add -A
  out=$(bash "$T/tests/test_no_secrets.sh" 2>&1)
  if [[ "$out" == *decoy.txt* ]]; then echo "ok   - caught: $d"; else echo "FAIL - not caught: $d"; fail=1; fi
  rm -rf "$T"
done
exit $fail
