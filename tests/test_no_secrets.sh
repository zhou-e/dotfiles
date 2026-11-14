#!/usr/bin/env bash
# Fails if personal/account data is in the repo's tracked or staged files.
# Run: bash tests/test_no_secrets.sh   (stage new files first: git add -A)
set -uo pipefail
cd "$(dirname "$0")/.."
patterns=(
  'awsapps\.com/start' 'ghp_[A-Za-z0-9]{20,}' 'gho_[A-Za-z0-9]{20,}' 'github_pat_[A-Za-z0-9_]{20,}'
  'AKIA[0-9A-Z]{16}' 'sk-ant-[A-Za-z0-9_-]+'
  'sso_start_url *= *https?://' 'sso_account_id *= *[0-9]'
  '"(oauthAccount|accessToken|refreshToken)" *: *[{"]'
  'aws_secret_access_key *= *[A-Za-z0-9/+]' 'BEGIN [A-Z ]*PRIVATE KEY'
  '(^|[^0-9])[0-9]{12}([^0-9]|$)'
)
fail=0
for p in "${patterns[@]}"; do
  hits=$(git grep --cached -nIE "$p" -- . ':!tests/test_no_secrets.sh' ':!tests/test_no_secrets_detects.sh' ':!.beads' 2>/dev/null)
  if [ -n "$hits" ]; then echo "FAIL - pattern '$p':"; echo "$hits" | sed 's/^/    /'; fail=1; fi
done
# Any email address except known-safe placeholders/bots.
allow='@(example\.(com|org|test)|anthropic\.com|users\.noreply\.github\.com)'
hits=$(git grep --cached -nIoE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' -- . ':!tests/test_no_secrets.sh' ':!tests/test_no_secrets_detects.sh' ':!.beads' 2>/dev/null | grep -vE "$allow")
if [ -n "$hits" ]; then echo "FAIL - email addresses:"; echo "$hits" | sed 's/^/    /'; fail=1; fi
[ $fail -eq 0 ] && echo "ok   - no secrets or personal data in tracked files"
exit $fail
