---
name: kb-update
description: Use after editing any codebase or after explaining/learning a new concept, to record it in the ~/kb wiki. Required before finishing such a turn; the Stop hook enforces it.
---
# kb-update
KB root: `~/kb` (read `~/kb/CLAUDE.md` for the schema if unsure).
1. Read `index.md`. Find existing pages for this project/concept; update rather than duplicate.
2. Project touched -> `wiki/projects/<project>.md`: purpose, architecture/key files, decisions and why, commands to build/test, gotchas, recent changes (date + one line).
3. Concept learned/explained -> `wiki/concepts/<concept>.md`: definition, why it matters, example, links `[[other-page]]`, sources. One concept per page.
4. If an outside source was used, save a note in `raw/` (or link) and cite it on the page.
5. Add/refresh the entry in `index.md` (one line per page: link + summary).
6. Append to `log.md`: `## [YYYY-MM-DD] <ingest|update> | <title>` plus a line on what changed.
7. Keep facts only, no secrets, no speculation presented as fact. Be brief: pages should be skimmable.
