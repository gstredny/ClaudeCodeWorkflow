---
name: stop
description: Generate a session-end summary that passes the stop hook on the first attempt
user_invocable: true
---

# /stop — Session-End Summary

The stop hook (`~/.claude/hooks/stop-require-summary.sh`) blocks exit until your summary contains **all 4 sections** below. Each section is validated by a regex — your text must match the pattern or the hook rejects it.

## Required Sections & Hook Patterns

### 1. What Changed
**Hook regex:** `\.(py|js|ts|jsx|tsx|go|rs|md|sh|json|yaml|yml|toml|css|html|vue|rb|java|kt|swift|c|cpp|h|hpp|sql|tf|hcl)\b`

You MUST mention file extensions. The hook counts occurrences of dotted extensions.

- Good: "Modified `executor.py` — added intent field. Created `SKILL.md` — new stop skill."
- Bad: "Updated the executor and created a skill file." (no extensions → blocked)

### 2. Test Results
**Hook regex:** `([0-9]+ (pass|fail|test|error|skip|succeed)|[0-9]+/[0-9]+|passed.*failed|tests?:?\s*[0-9])`

You MUST include numeric counts next to test keywords.

- Good: "560 passed, 0 failed" or "12/12 tests passed"
- Bad: "All tests pass" or "Tests are green" (no numbers → blocked)

### 3. What's Left
**Hook regex:** `(what's left|remaining|next steps|left to do|todo|still need|left off|nothing.*(left|remain))`

You MUST use one of the trigger phrases above.

- Good: "What's left: deploy to staging and run integration tests."
- Good: "Nothing remaining — all done criteria met."
- Bad: "Future work includes..." (no trigger phrase → blocked)

### 4. Task File Status
**Hook regex:** `(task file (updated|unchanged)|task file.*docs/tasks/open/.*\.md|no scope.*change|no criteria.*change)`

You MUST declare whether the task file was updated or unchanged.

- Good: "Task file updated: docs/tasks/open/wave2a-powerbi-tool-gaps.md"
- Good: "Task file unchanged — no scope/criteria changes"
- Bad: "The task is tracked in docs." (no trigger phrase → blocked)

## Template

Copy and fill in:

```
**What changed:**
- Modified `<file>` — <what changed>
- Created `<file>` — <what changed>

**Test results:** <N> passed, <N> failed (or "No tests required — documentation-only change")

**What's left:** <next steps, or "Nothing remaining">

**Task file status:** Task file updated: docs/tasks/open/<name>.md (or "Task file unchanged — no scope/criteria changes")
```

## Common Mistakes

| Mistake | Why it fails | Fix |
|---------|-------------|-----|
| "Updated the service" | No file extension | "Updated `service.py`" |
| "Tests pass" | No numbers | "560 passed, 0 failed" |
| "Will do X next time" | No trigger phrase | "What's left: X" |
| Omitting task file line | Missing section 4 | Add "Task file updated/unchanged" line |
