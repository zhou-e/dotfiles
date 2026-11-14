---
name: kb-lint
description: Use periodically (or when asked) to health-check the ~/kb wiki for broken links, orphans, stale or contradictory pages.
---
# kb-lint
1. List all pages in `wiki/`; compare against `index.md` (missing entries, orphan pages).
2. Check every `[[link]]` resolves to a page; check for duplicate concepts and contradictions.
3. Flag pages whose "recent changes" are old relative to the code they describe.
4. Fix what is safe (links, index entries); list the rest for the user. Append a `lint` entry to `log.md`.
