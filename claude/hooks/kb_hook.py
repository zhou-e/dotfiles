#!/usr/bin/env python3
"""Claude Code hook that keeps the kb (~/kb) in sync with work.

Modes (argv[1]):
  session-start : inject a reminder + kb index location as context.
  track         : PostToolUse on Edit/Write/MultiEdit; record touched files.
  stop          : Stop hook; block once if non-kb files were edited but kb was not.
Override the kb location with the KB_DIR environment variable.
Fails open: any error exits 0 so it never breaks a session.
"""
import json, os, sys

HOME = os.path.expanduser("~")
KB = os.path.normcase(os.path.abspath(os.environ.get("KB_DIR", os.path.join(HOME, "kb"))))
CLAUDE_DIR = os.path.normcase(os.path.abspath(os.path.join(HOME, ".claude")))
STATE = os.path.join(HOME, ".claude", "kb-state")


def norm(p):
    return os.path.normcase(os.path.abspath(os.path.expanduser(p)))


def under(p, root):
    return p == root or p.startswith(root + os.sep)


def state_path(sid):
    os.makedirs(STATE, exist_ok=True)
    return os.path.join(STATE, "".join(c for c in sid if c.isalnum() or c in "-_") + ".json")


def load(sid):
    try:
        with open(state_path(sid), encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {"code": [], "kb": False, "blocked": False}


def save(sid, s):
    with open(state_path(sid), "w", encoding="utf-8") as f:
        json.dump(s, f)


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    try:
        data = json.load(sys.stdin)
    except Exception:
        data = {}
    sid = data.get("session_id") or "default"

    if mode == "session-start":
        msg = (f"Knowledge base at {KB}. Read index.md before working in a known project/topic. "
               "After editing code or teaching/learning a concept, run the kb-update skill before finishing.")
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": msg}}))
        return

    if mode == "track":
        fp = (data.get("tool_input") or {}).get("file_path")
        if not fp:
            return
        p = norm(fp)
        s = load(sid)
        # ~/kb may be a symlink (to ~/.code/kb/main): match the path as given and resolved.
        kb_roots = {KB, os.path.normcase(os.path.realpath(KB))}
        paths = {p, os.path.normcase(os.path.realpath(p))}
        if any(under(x, r) for x in paths for r in kb_roots):
            s["kb"] = True
            s["blocked"] = False
        elif not under(p, CLAUDE_DIR):
            if p not in s["code"]:
                s["code"].append(p)
        save(sid, s)
        return

    if mode == "stop":
        s = load(sid)
        if data.get("stop_hook_active") or s.get("blocked"):
            return  # never loop
        if s["code"] and not s["kb"]:
            s["blocked"] = True
            save(sid, s)
            files = ", ".join(os.path.basename(f) for f in s["code"][:8])
            reason = (f"You edited files this session ({files}) but did not update the knowledge base at {KB}. "
                      "Run the kb-update skill now: update the project page in wiki/projects/, add/refresh any "
                      "concept pages in wiki/concepts/, update index.md and append to log.md. Then finish.")
            print(json.dumps({"decision": "block", "reason": reason}))
        return


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
