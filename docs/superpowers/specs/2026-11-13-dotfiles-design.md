# Dotfiles + kb repos: design

Approved 2026-11-13.

## Intent

Reproduce this machine's setup (Claude Code config, status line, beads, shell, git, tmux)
on other machines, and record anything that can't be copied as a file.

## Goals
- One public `dotfiles` repo and one private `kb` repo.
- A bootstrap you can run again safely, with every dependency written down.
- The README lists all the software the setup relies on (beads, tmux, Node, gh, ...).

## Non-goals
- Copying upstream skill packs (Superpowers, AWS). Document where they come from instead.
- Managing secrets. Supporting macOS or Windows.

## Anti-goals
- Personal identity or account details in the public repo: email, OAuth tokens,
  AWS account IDs, SSO URLs.

## Approaches
- **A, chosen:** symlinks plus `install.sh`. Files that their own apps rewrite
  (`~/.claude/settings.json`, ccstatusline config) are copied instead, and `capture.sh`
  copies them back. No extra tools, and drift shows up in `git status`.
- B, rejected: copy everything. Every change needs a capture step and drift goes unnoticed.
- C, rejected: GNU stow / chezmoi. An extra dependency on every machine, overkill for this many files.

## Decided
- Repos: `~/.code/dotfiles/main` (public) and `~/.code/kb/main` (private).
  `~/kb` becomes a symlink to the kb repo.
- Git identity lives in an untracked `~/.gitconfig.local`, pulled in via `[include]`.
- The `.bashrc` additions live in `shell/bashrc.d/dotfiles.sh`; `install.sh` adds a single
  idempotent `source` line to `~/.bashrc`.
- `claude/statusline.sh` finds the newest nvm Node at runtime, so no version paths are hardcoded.
- tmux: `prefix |` is a left/right split (`split-window -h`), `prefix v` is a top/bottom split
  (`split-window -v`). Both open in the current pane's directory.
- `gh` is installed from the GitHub release tarball into `~/.local/bin` (no sudo).
- Beads in both repos. No remotes or pushes until the user asks.

## Left to the builder
- README wording; which `.bashrc` lines move into the snippet (PATH + nvm).
