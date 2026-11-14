#!/usr/bin/env bash
# Tests install.sh and capture.sh against a throwaway HOME. Run: bash tests/test_install.sh
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
check() { if eval "$2"; then echo "ok   - $1"; else echo "FAIL - $1"; fail=1; fi; }

H=$(mktemp -d); trap 'rm -rf "$H" "$R"' EXIT
printf 'old tmux\n' > "$H/.tmux.conf"
printf '[user]\n\tname = Keep Me\n' > "$H/.gitconfig.local"
printf '# existing bashrc\n' > "$H/.bashrc"
mkdir -p "$H/.claude/skills/kb-update" && printf 'old skill\n' > "$H/.claude/skills/kb-update/SKILL.md"

HOME="$H" bash "$REPO/install.sh" >/dev/null 2>&1; rc=$?
check "install exits 0 (rc=$rc)" '[ $rc -eq 0 ]'
for t in .claude/CLAUDE.md .claude/hooks/kb_hook.py .claude/statusline.sh .claude/skills/kb-update .claude/skills/git-workflow .bashrc.d/dotfiles.sh .gitconfig .tmux.conf; do
  check "link $t -> repo" '[ -L "$H/$t" ] && [[ "$(readlink -f "$H/$t")" == "$REPO"/* ]]'
done
check "settings.json copied (not a link)" '[ -f "$H/.claude/settings.json" ] && [ ! -L "$H/.claude/settings.json" ] && cmp -s "$H/.claude/settings.json" "$REPO/claude/settings.json"'
check "ccstatusline settings copied" '[ -f "$H/.config/ccstatusline/settings.json" ] && [ ! -L "$H/.config/ccstatusline/settings.json" ]'
check "old .tmux.conf backed up outside its folder" '[ "$(ls "$H"/.dotfiles-backup/*/.tmux.conf 2>/dev/null | wc -l)" -eq 1 ] && grep -q "old tmux" "$H"/.dotfiles-backup/*/.tmux.conf'
check "no in-place .bak files (skills dir would load them)" '[ -z "$(find "$H" -name "*.bak.*" -not -path "*/.dotfiles-backup/*")" ]'
check ".gitconfig.local untouched" 'grep -q "Keep Me" "$H/.gitconfig.local"'

sleep 1; HOME="$H" bash "$REPO/install.sh" >/dev/null 2>&1; rc=$?
check "second install exits 0 (rc=$rc)" '[ $rc -eq 0 ]'
check "bashrc source line exactly once" '[ "$(grep -cF ". ~/.bashrc.d/dotfiles.sh" "$H/.bashrc")" -eq 1 ]'
check "still exactly one tmux backup" '[ "$(ls "$H"/.dotfiles-backup/*/.tmux.conf | wc -l)" -eq 1 ]'
check "no backups of our own links" '[ -z "$(ls -d "$H"/.dotfiles-backup/*/.gitconfig "$H"/.dotfiles-backup/*/.claude/CLAUDE.md 2>/dev/null)" ]'

# existing ~/.gitconfig identity is carried into .gitconfig.local (not placeholders)
H3=$(mktemp -d); printf '[user]\n\tname = Old Name\n\temail = old@example.test\n' > "$H3/.gitconfig"
HOME="$H3" bash "$REPO/install.sh" >/dev/null 2>&1
check "existing git identity preserved" '[ "$(HOME="$H3" git config --includes --global user.email)" = old@example.test ]'
rm -rf "$H3"

# fresh HOME without .gitconfig.local gets the template
H2=$(mktemp -d); HOME="$H2" bash "$REPO/install.sh" >/dev/null 2>&1
check "gitconfig.local template created when missing" 'grep -q "you@example.com" "$H2/.gitconfig.local"'
check "template identity is commented out (git refuses to commit)" '[ -z "$(HOME="$H2" git config --includes --global user.email)" ]'
rm -rf "$H2"

# capture copies home -> repo (against a temp copy of the repo)
R=$(mktemp -d); cp -r "$REPO/." "$R/"
printf '{"captured": true}\n' > "$H/.claude/settings.json"
HOME="$H" REPO="$R" bash "$R/capture.sh" >/dev/null 2>&1; rc=$?
check "capture exits 0 (rc=$rc)" '[ $rc -eq 0 ]'
check "capture copied settings.json into repo" 'grep -q captured "$R/claude/settings.json"'
check "capture left real repo alone" '! grep -q captured "$REPO/claude/settings.json"'
exit $fail
