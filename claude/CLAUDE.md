# User-level instructions (applies to every project)

Keep this file short. Detailed procedures live in skills; load them instead of improvising.

## Workflow
- For any non-trivial task, start with the `using-superpowers` skill, then follow it:
  brainstorming -> writing-plans -> executing-plans / subagent-driven-development.
- Use `test-driven-development` for features and bug fixes, `systematic-debugging` before
  proposing any fix, and `verification-before-completion` before saying work is done
  (run the tests/build and read the output; never claim success from memory).
- Ask before large or irreversible actions. Keep replies short; lead with the outcome.

## Project location
- All projects live under `~/.code/<project>/`, which is a plain folder (NOT a git repo). Never nest checkouts inside another checkout.
- Layout: `~/.code/<project>/main/` is the primary checkout (clone with `git clone <url> ~/.code/<project>/main`);
  every other branch is its own git worktree at `~/.code/<project>/<branch>/`, created from `main/` with
  `git worktree add ../<branch> -b <branch>`. Use dashes in folder names (`feat-login`, not `feat/login`).
  No `.worktrees/` dir and no gitignore/exclude setup needed. This is the declared preference for `using-git-worktrees`
  (if a native worktree tool places them elsewhere, use `git worktree add` instead).
- Run git commands from inside `main/` or a branch folder, never from `~/.code/<project>/` itself.

## Beads (task tracking + session memory)
- `bd` (beads, installed at ~/.local/bin) is the TODO list and notes tracker. It preserves context between sessions.
  A global SessionStart hook runs `bd prime`, which injects open work and memories automatically.
- ALWAYS use beads when entering a repo or worktree. First check `bd where` (or `ls .beads`). If no beads
  workspace exists, create one before any other work: `bd init --non-interactive --skip-hooks --skip-agents --prefix <project>` (the flags avoid git hooks and Codex/Cursor/AGENTS.md clutter; the global hook already provides context; without --prefix the prefix becomes "main") (run in the main
  checkout at ~/.code/<project>/main, never in a branch worktree).
- Worktrees share the main checkout's `.beads` database, so tasks are visible from every worktree. Do not run
  `bd init` inside a branch worktree if `bd where` already resolves to the main repo.
- Start of work: `bd ready`. Track every non-trivial task: `bd create "Title" -p <0-4>`, claim with
  `bd update <id> --claim`, record progress with `bd update <id> --append-notes "..."`, link with `bd dep add`,
  finish with `bd close <id>`. Use `bd remember "insight"` for durable project facts.
- Before ending a session: close finished issues and append notes to in-progress ones so the next session can resume.
- Beads holds tasks and progress notes; `~/kb` holds concepts and project documentation.

## Git
- ALWAYS commit finished, verified work on the feature branch without asking (commits are cheap and
  reversible; unsaved work is not). Opening a PR (and pushing for it) requires asking. Never force-push shared branches.
- Work on a feature branch (not main/master); use `using-git-worktrees` for parallel work.
- Conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`), small and
  focused. Use `git-workflow` for commit/branch/PR steps and `finishing-a-development-branch`
  to wrap up. Request review via `requesting-code-review` before merging.
- Run tests and `git diff --staged` before every commit. Never commit secrets or .env files.

## Knowledge base (kb) at ~/kb
- Schema and rules: `~/kb/CLAUDE.md`. Entry point: `~/kb/index.md`.
- Before working in a project or topic, check `index.md` and read the relevant wiki page.
- REQUIRED: after you touch a codebase (any file edit) OR explain/learn a new concept, update
  the kb with the `kb-update` skill BEFORE finishing the turn. Do not wait to be asked.
  Project page = `wiki/projects/<name>.md`; concept page = `wiki/concepts/<name>.md`.
- Hooks enforce this: a Stop hook blocks finishing if code was edited and the kb was not
  updated this session. Hook script: `~/.claude/hooks/kb_hook.py` (needs `python3` on PATH).
- Use `kb-query` to answer from the kb and `kb-lint` periodically to fix broken links/orphans.
- Never store secrets, tokens, or personal data in the kb.
