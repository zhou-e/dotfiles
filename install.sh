#!/usr/bin/env bash
# Put the dotfiles in place. Safe to re-run.
# - Symlinks most files into $HOME (edits anywhere land in the repo).
# - Copies files that their apps rewrite (a rewrite can replace a symlink);
#   bring those back with ./capture.sh.
# - Anything already at a target that isn't our link is moved to ~/.dotfiles-backup/<timestamp>/.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

BACKUP="$HOME/.dotfiles-backup/$STAMP"
backup() {  # move a real file/dir (or foreign link) to ~/.dotfiles-backup/<stamp>/<same path>
  # Not in place: a *.bak copy left in ~/.claude/skills/ would load as a duplicate skill.
  local dst=$1 rel
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    rel="${dst#"$HOME"/}"
    mkdir -p "$BACKUP/$(dirname "$rel")"
    mv "$dst" "$BACKUP/$rel"; echo "backup  $dst -> $BACKUP/$rel"
  fi
}

link() {  # link <repo-relative src> <home target>
  local src="$REPO/$1" dst=$2
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
  backup "$dst"
  ln -s "$src" "$dst"; echo "link    $dst -> $src"
}

copy() {  # copy <repo-relative src> <home target>
  local src="$REPO/$1" dst=$2
  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ] && [ ! -L "$dst" ] && cmp -s "$src" "$dst"; then return; fi
  backup "$dst"
  cp "$src" "$dst"; echo "copy    $src -> $dst"
}

# Claude Code
link claude/CLAUDE.md          "$HOME/.claude/CLAUDE.md"
link claude/hooks/kb_hook.py   "$HOME/.claude/hooks/kb_hook.py"
link claude/statusline.sh      "$HOME/.claude/statusline.sh"
for s in "$REPO"/claude/skills/*/; do
  s=$(basename "$s"); link "claude/skills/$s" "$HOME/.claude/skills/$s"
done
copy claude/settings.json      "$HOME/.claude/settings.json"
copy ccstatusline/settings.json "$HOME/.config/ccstatusline/settings.json"

# Shell, git, tmux
link shell/bashrc.d/dotfiles.sh "$HOME/.bashrc.d/dotfiles.sh"
line='[ -f ~/.bashrc.d/dotfiles.sh ] && . ~/.bashrc.d/dotfiles.sh'
touch "$HOME/.bashrc"
grep -qxF "$line" "$HOME/.bashrc" || { printf '\n%s\n' "$line" >> "$HOME/.bashrc"; echo "append  source line -> ~/.bashrc"; }
# Identity goes in untracked ~/.gitconfig.local. Seed it before ~/.gitconfig is replaced:
# carry over an existing [user] if there is one, otherwise use the (commented-out) template
# so git refuses to commit until you fill it in.
if [ ! -e "$HOME/.gitconfig.local" ] && [ ! -L "$HOME/.gitconfig.local" ]; then
  name=$(git config --file "$HOME/.gitconfig" --get user.name 2>/dev/null || true)
  email=$(git config --file "$HOME/.gitconfig" --get user.email 2>/dev/null || true)
  if [ -n "$name" ] && [ -n "$email" ]; then
    printf '[user]\n\tname = %s\n\temail = %s\n' "$name" "$email" > "$HOME/.gitconfig.local"
    echo "create  ~/.gitconfig.local (identity carried over from old ~/.gitconfig)"
  else
    cp "$REPO/git/gitconfig.local.example" "$HOME/.gitconfig.local"
    echo "create  ~/.gitconfig.local (EDIT IT: set your git name/email)"
  fi
fi
link git/gitconfig  "$HOME/.gitconfig"
link tmux/tmux.conf "$HOME/.tmux.conf"

echo "done. See README.md for what isn't handled here (logins, AWS, SSH, skill packs)."
