---
name: workflow
description: 6-phase development workflow for declarative task execution across Claude.ai and Claude Code sessions
---

# Development Workflow

A 6-phase loop for taking features and bugs from idea to verified completion. Task files are persistent memory. Only the user closes tasks.

## Philosophy

- **Declarative, not imperative.** Define success criteria and constraints — let Claude figure out the approach. This gives room to loop, try alternatives, and self-correct.
- **Task files are persistent memory.** Claude Code doesn't remember between sessions. Task files in `docs/tasks/open/` ARE the memory — every session reads the file, sees what was tried, and resumes.
- **Only the user can close a task.** Claude sets status to "needs verification" — never "done." The user tests, confirms each Done Criterion, and says "close it out."

## The 6 Phases

| Phase | Where | Who Drives | Output |
|-------|-------|-----------|--------|
| 1. Plan | Claude.ai | User + Claude.ai | Success criteria, constraints, execution mode |
| 2. Explore | Claude Code | Claude | Task file created, codebase explored, plan generated |
| 3. Review | Claude.ai | Claude.ai | Plan challenged, improved, agents assigned if team mode |
| 4. Execute | Claude Code | Claude | Code changes implemented, attempts logged after every change |
| 5. Verify | Claude Code + User | User | Done Criteria walked through one by one |
| 6. Close-out | Claude Code | User | Retro entry appended, task moved to closed/ |

**Phase 1 — Plan:** Come to Claude.ai with a feature or bug. Together define success criteria (specific, testable), tests that prove it works, constraints (what NOT to do), and whether to use single-agent or agent-team execution.

**Phase 2 — Explore:** Paste the prompt into Claude Code. Always check `docs/tasks/open/` first. Either resume an existing task or create a new one. Explore the codebase and generate a plan.

**Phase 3 — Review:** Bring the plan back to Claude.ai. Challenge assumptions, check for over-engineering, verify it's a real fix (not a band-aid). For agent teams, assign file ownership with zero overlap.

**Phase 4 — Execute:** Implement the plan. After EVERY code change attempt, append to the task file's Attempts log immediately (not batched). Attempts log is append-only — never overwrite or delete entries.

**Phase 5 — Verify:** When code compiles, tests pass, and changes are committed, set status to "needs verification" and walk through each Done Criterion with the user. User confirms or rejects each one.

**Phase 6 — Close-out:** User says "close it out." Append a retro entry (use the retro skill for format), then move the task file from `docs/tasks/open/` to `docs/tasks/closed/`.

## Declarative Prompting

**Include:** Success criteria, tests that prove it works, constraints, relevant context.

**Do NOT include:** Step-by-step implementation instructions, specific line numbers to change, exact code to write.

Good:
> "Success criteria: The /api/users endpoint returns paginated results with correct schema. All date fields use ISO 8601 format. Constraint: Don't add new database tables."

Bad:
> "Fix user_service.py line 312. Change the mapping from 'active' to match the schema. Then update the test. Then run pytest."

The declarative version lets Claude explore, loop, and self-correct. The imperative version breaks if line numbers shift or the mapping needs a different approach.

## Session Hygiene

**Start every session:** Check `docs/tasks/open/` first. If a task matches the current work, read it and resume from "Left Off At." Never retry approaches logged in Attempts.

**End every session:** Summarize what changed, test results, and what's left. Update the task file's "Left Off At" with a specific resumption point.

## Agent Teams

Use agent teams when ALL four criteria are met:

1. Work spans **multiple files** with clear ownership boundaries
2. Tasks can run **independently in parallel** (no sequential dependencies)
3. Each piece produces a **clear deliverable** (a function, a test file, a component)
4. Time savings from parallelization **outweigh coordination overhead**

Quick decision check: *"Can I draw file-ownership lines with zero overlap?"* Yes → team candidate. No → single agent.

**Team execution rules:** Lead agent uses delegate mode, owns the task file exclusively. Teammates report via messaging. Lead logs teammate work to Attempts with role tags (e.g., `[Teammate: API]`).

## Decision Tree

| User Says | Action |
|-----------|--------|
| "Fix this bug" / "Add this feature" | Check `docs/tasks/open/` for existing task → create task file if none → explore → plan |
| "Check tasks" / "What's open?" | List all files in `docs/tasks/open/` with Status and Goal |
| "Resume [task name]" | Read the task file, pick up from "Left Off At", never retry failed Attempts |
| "Close it out" | Append retro entry (see retro skill), move task to `docs/tasks/closed/` |
| "Use a team for this" | Verify 4 agent-team criteria, set up team structure with file ownership map |
| "What was tried?" | Read the task file's Attempts section and summarize |

## Cross-References

- **Task file CRUD rules and template:** See the task-manager skill
- **Retro entry format and rules:** See the retro skill
- **Plan self-check before execution:** See the plan-review skill
- **Hook enforcement:** Workflow rules are enforced by automated hooks — task status, venv activation, retro-before-close, and session close-out summaries
