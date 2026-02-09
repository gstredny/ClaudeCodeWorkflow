---
name: retro
description: Retrospective entry format for capturing lessons learned at task close-out
---

# Retro Entry

Append a retrospective entry to `docs/tasks/RETRO.md` when closing out a task. Entries capture what was learned — not what was done.

## When

At task close-out only, after the user says "close it out" and all Done Criteria are confirmed. Write the entry before moving the task file to `docs/tasks/closed/`.

## Where

Append to `docs/tasks/RETRO.md`. Never edit or delete previous entries — the log is append-only.

## Entry Format

```markdown
### [YYYY-MM-DD] Task: [task name]
- **What worked:** [approaches worth repeating]
- **What broke:** [failures to avoid next time]
- **Workflow friction:** [process issues, not code issues — or "None"]
- **Pattern:** [generalizable lesson for future tasks]
```

## What Makes a Good Pattern

The Pattern field is the most important part. It should be a generalizable lesson that applies beyond this specific task.

Good patterns:
- "When replacing factory imports with DI, update all test fixtures that patch old names in the same commit" — generalizable, actionable, prevents a specific class of bug
- "When creating CI pipelines, treat the first run failure as expected — it catches implicit dependencies" — transferable lesson, changes how you approach a situation

Bad patterns:
- "Fixed the user service mapping" — describes a specific fix, not a lesson
- "Updated 7 lines in auth_service.py" — describes what was done, not what was learned

A good test: could someone working on a completely different task benefit from reading this pattern? If yes, it's generalizable. If no, rewrite it.

## Hook Enforcement

A pre-tool-use hook blocks moving task files to `docs/tasks/closed/` unless a matching retro entry exists in `docs/tasks/RETRO.md`. The entry must contain the task name in its heading.
