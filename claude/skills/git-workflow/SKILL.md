---
name: git-workflow
description: Use when committing, branching, opening a PR, or cleaning up git history. Conventional commits, small focused changes, verify before commit.
---
# Git workflow
1. `git status` and `git diff` first; confirm which branch you are on. Never work directly on main/master: create `feat/<short>`, `fix/<short>` or `chore/<short>`.
2. Run the project's tests/linter. Read the output. Do not commit on red.
3. Stage deliberately (`git add -p` or named paths), never `git add -A` blindly; check `git diff --staged` for secrets, .env, large binaries, debug code.
4. Commit message: `type(scope): imperative summary` (<=72 chars), blank line, body explaining WHY. Types: feat, fix, docs, refactor, test, chore, perf, ci.
5. One logical change per commit. Prefer new commits over amending pushed ones; never force-push shared branches (`--force-with-lease` on your own branch only if asked).
6. Only commit/push/PR when the user asked. PR description: what changed, why, how tested, risks. Then use `requesting-code-review` and `finishing-a-development-branch`.
7. After finishing, run `kb-update` to record the change in the project's kb page.
