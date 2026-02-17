# Hooks = Automated Enforcement

### Shell scripts that fire on Claude Code events

| Hook | What It Does |
|------|-------------|
| **session-start** | Injects workflow rules + recent retro entries |
| **stop-require-summary** | Blocks stopping without close-out summary |
| **guard-task-status** | Prevents attempts log overwrites |
| **close-out-preflight** | Checks done criteria, retro entry, and code review in one pass |
| **teammate-require-summary** | Requires completion report from teammates |
| **require-venv** | Blocks Python commands without venv |
| **task-require-tests** | Runs tests before task completion |

### Two levels:

- **Global hooks** (`~/.claude/hooks/`) — workflow rules, all projects
- **Project hooks** (`.claude/hooks/`) — customizable per language/stack

### How they work:

- Exit 0 = allow
- Exit 2 + stderr message = block with explanation

---

**Speaker notes:**
Rules in CLAUDE.md work because Claude reads them. Hooks work even when Claude doesn't. They're the safety net. Global hooks are install-once, work-everywhere. Project hooks are customized — Python projects check for venv, Node projects could check for node_modules, etc.
