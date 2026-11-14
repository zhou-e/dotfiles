# dotfiles

My Linux (Ubuntu / WSL2) setup: Claude Code config and workflow skills, a token-usage
status line, beads task tracking, bash, git and tmux.

## Quick start (new machine)

```bash
git clone https://github.com/zhou-e/dotfiles.git ~/.code/dotfiles/main && cd ~/.code/dotfiles/main
sudo apt install -y tmux python3 git curl gh   # system packages (gh optional: see below)
./bootstrap/deps.sh      # nvm + Node LTS, ccstatusline, gh (if missing), beads; no sudo
./install.sh             # link/copy configs into $HOME (moves anything it replaces to ~/.dotfiles-backup/)
$EDITOR ~/.gitconfig.local   # check git name/email (carried over from an old ~/.gitconfig, else a template to fill in)
exec bash                # reload the shell (PATH, nvm)
```

Then do the manual steps in [Not stored here](#not-stored-here).

## Software

| Software | What it's for | How it gets installed |
|---|---|---|
| **Claude Code** (`claude`) | AI coding CLI that all of `claude/` configures | `curl -fsSL https://claude.ai/install.sh \| bash` (manual; `deps.sh` reminds you) |
| **beads** (`bd`) | Task tracker / session memory; `bd prime` runs from a Claude SessionStart hook | `deps.sh` (upstream `steveyegge/beads` install script → `~/.local/bin/bd`) |
| **tmux** | Terminal multiplexer, config in `tmux/tmux.conf` | `sudo apt install tmux` |
| **nvm** + **Node.js LTS** | Runtime for ccstatusline | `deps.sh` (nvm v0.40.3, then `nvm install --lts`) |
| **ccstatusline** | Claude Code status line: tokens in/out/cached/total, context %, session cost | `deps.sh` (`npm i -g ccstatusline`) |
| **gh** (GitHub CLI) | GitHub repos/PRs from the terminal | `sudo apt install gh`, or `deps.sh` installs the latest release tarball to `~/.local/bin` |
| **python3** | Runs the kb hook (`claude/hooks/kb_hook.py`) | `sudo apt install python3` (preinstalled on Ubuntu) |
| **git** | Version control (config in `git/`) | `sudo apt install git` |
| **AWS CLI v2** | AWS access via SSO profiles | Manual: [install guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), with `./aws/install -i ~/.local/aws-cli -b ~/.local/bin` for a no-sudo install |
| curl | Used by `deps.sh` | `sudo apt install curl` |

## What's in here

| Repo path | Goes to | How |
|---|---|---|
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | link |
| `claude/hooks/kb_hook.py` | `~/.claude/hooks/kb_hook.py` | link |
| `claude/statusline.sh` | `~/.claude/statusline.sh` | link |
| `claude/skills/{git-workflow,kb-lint,kb-query,kb-update}` | `~/.claude/skills/…` | link (dir) |
| `claude/settings.json` | `~/.claude/settings.json` | **copy** |
| `ccstatusline/settings.json` | `~/.config/ccstatusline/settings.json` | **copy** |
| `shell/bashrc.d/dotfiles.sh` | `~/.bashrc.d/dotfiles.sh` (+ one `source` line appended to `~/.bashrc`) | link |
| `git/gitconfig` | `~/.gitconfig` (includes untracked `~/.gitconfig.local`) | link |
| `tmux/tmux.conf` | `~/.tmux.conf` | link |

**Linked** files are the repo: edit them anywhere and `git status` shows it.
**Copied** files get rewritten by their own apps (Claude Code's `/config`, the ccstatusline
menu), and a rewrite can replace a symlink. After changing them, run `./capture.sh` to copy them
back into the repo, then review with `git diff`.

### Claude Code settings (`claude/settings.json`)
- Hooks: kb reminders/enforcement (`kb_hook.py`, needs `~/kb`), and `bd prime` at session start (needs `bd`).
- `statusLine` runs `~/.claude/statusline.sh`. That script finds the newest nvm Node itself,
  because Claude Code runs it in a non-interactive shell where nvm isn't loaded. If you use the
  ccstatusline setup menu (`ccstatusline` in a terminal), check afterwards that
  `statusLine.command` is still `$HOME/.claude/statusline.sh`.
- `CLAUDE_CODE_SUBAGENT_MODEL` env var and default model.

### tmux
| Keys | Action |
|---|---|
| `prefix` then `\|` | split left/right (new pane in the current directory) |
| `prefix` then `v` | split top/bottom (new pane in the current directory) |

## Not stored here

These can't or shouldn't be in a public repo. Recreate them by hand:

| What | Why not stored | How to recreate |
|---|---|---|
| `~/.claude.json`, `~/.claude/.credentials.json` | Login tokens, account and machine IDs | Run `claude` and log in |
| `~/.gitconfig.local` | Name/email | `install.sh` carries over `[user]` from an existing `~/.gitconfig`, otherwise copies the commented-out template (git refuses to commit until you fill it in) |
| `~/.aws/config`, `~/.aws/sso` | Account IDs, SSO URL | `aws configure sso` (profile `personal-pu`, SSO session `personal`), then `aws sso login --profile personal-pu` |
| `~/.ssh/` | Private keys | Generate new keys (`ssh-keygen -t ed25519`) and add them to GitHub, or copy them over privately |
| gh login | Token | `gh auth login` |
| Superpowers skills (`brainstorming`, `writing-plans`, `test-driven-development`, …) | Third-party (MIT), has its own upstream | Install the Superpowers skills from upstream ([obra/superpowers](https://github.com/obra/superpowers)) into `~/.claude/skills/` |
| AWS skills (`aws-*`, `amazon-bedrock`, `launch-with-aws`, `signing-in-to-aws`) | Third-party, has its own upstream | Reinstall from AWS's agent skills pack into `~/.claude/skills/`. **The source URL wasn't recorded on the original machine (installed 2026-11-13); add it here once known.** |
| Plugin marketplace `claude-plugins-official` | Managed by Claude Code | In Claude Code: `/plugin marketplace add anthropics/claude-plugins-official` |
| `~/kb` (knowledge base) | Private notes | `gh repo clone zhou-e/kb ~/.code/kb/main` (private; needs `gh auth login`), then `ln -s ~/.code/kb/main ~/kb` |
| Beads databases (`.beads/` in each project) | Per-project data | Created by `bd init` per project (see `claude/CLAUDE.md`) |

## Tests

```bash
bash tests/test_statusline.sh   # status line renders; falls back when Node is missing
bash tests/test_install.sh      # install/capture against a throwaway $HOME
bash tests/test_kb_hook.sh      # kb hook counts kb edits via symlink or real path
git add -A && bash tests/test_no_secrets.sh   # no emails/tokens/account IDs in tracked files
```

## Layout conventions

Projects live at `~/.code/<project>/main` with branch worktrees beside it (see `claude/CLAUDE.md`).
This repo is `~/.code/dotfiles/main`.
