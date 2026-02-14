# Task File Template

Copy this template to `docs/tasks/open/[descriptive-name].md` when starting a new task.

---

## Task: [name]
## Status: not started | in progress | blocked | needs verification
## Execution Mode: single-agent | agent-team
## Code Review: required | not required | in progress | completed
## Goal: [one sentence — the outcome, not the approach]

## Relevant Files:
- [only files this task touches, with brief note on what changes]

## Context:
[only decisions and findings relevant to THIS task — not general project context]

## Done Criteria:
- [ ] [specific testable criterion]
- [ ] [specific testable criterion]

## Team Structure (agent-team mode only):
- Lead: delegate mode, owns task file
- Teammate 1 [Role]: [assigned files] — [objective]
- Teammate 2 [Role]: [assigned files] — [objective]

## File Ownership Map (agent-team mode only):
| Teammate | Files | Constraint |
|----------|-------|------------|
| [Role]   | [specific files] | [what NOT to touch] |

## Left Off At:
[exactly where work stopped — be specific enough that a new session can resume without asking questions]

## Attempts:
- [date] [Teammate: role if team mode]: what was tried → what happened → result (worked/failed/partial)

## Code Review Findings:
- [date]: [severity/category] [file:line] [finding] → [resolution] (fixed/wontfix/deferred)

---

## Field Guide

### Status
- **not started** — Task created but no work begun
- **in progress** — Actively being worked on
- **blocked** — Cannot continue; describe blocker in Context
- **needs verification** — Fix appears to work; waiting for user to confirm Done Criteria

Never set to "done" or "complete" — only the user can close a task.

### Goal
One sentence describing the desired OUTCOME, not the approach.
- Good: "Users can log in with SSO and see their dashboard within 3 seconds"
- Bad: "Fix line 312 in service.py to change the mapping"

### Done Criteria
Each criterion must be independently testable. Use checkboxes. Examples:
- [ ] `pytest tests/test_feature.py` passes with 0 failures
- [ ] API response includes `status` field with value "active"
- [ ] No console errors on page load

### Attempts (Append-Only)
Log EVERY attempt immediately after trying it. Never delete or overwrite entries.

Format: `- [YYYY-MM-DD]: what was tried → what happened → result`

For agent teams, tag by role: `- [YYYY-MM-DD] [Teammate: API]: ...`

### Left Off At
Must be specific enough for a cold resume. Bad: "Working on it." Good: "Implemented the query change in service.py:312. Need to update test_service.py to match new return schema. The test currently expects 3 columns but the query now returns 5."

### Code Review
- **required** — Default for all tasks that modify code. Code review must be completed before close-out.
- **not required** — Explicitly opted out (documentation-only, config changes, non-code tasks). Set during Phase 1 planning or with user approval.
- **in progress** — Code review sub-loop is actively being worked on.
- **completed** — All review findings addressed. Ready for close-out.

A hook enforces this: task files cannot be moved to `docs/tasks/closed/` unless Code Review is "completed" or "not required."

### Code Review Findings (Append-Only)
Log every code review finding immediately when discovered. Never delete or overwrite entries.

Format: `- [YYYY-MM-DD]: [severity/category] [file:line] [finding] → [resolution] (fixed/wontfix/deferred)`

Severity: `critical`, `major`, `minor`, `nit`
Categories: `bug`, `edge-case`, `security`, `performance`, `architecture`, `style`, `test-gap`
