# CLAUDE.md

[CUSTOMIZE: Your project name] -- Claude Code guidance.

## Task Management (STOP -- READ BEFORE DOING ANYTHING)

**BEFORE ANY WORK:**
- Check `docs/tasks/open/` for matching task. If found -> read it, announce where we left off, resume from there. **NEVER retry failed approaches** (check Attempts log).
- If NOT found -> IMMEDIATELY create `docs/tasks/open/[descriptive-name].md` from template below. **No task file = no work allowed.**
- Session starts without task specified -> list all files in `docs/tasks/open/` with Status/Goal, ask which to work on.

**DURING WORK:**
- After EVERY code change attempt -> append to Attempts immediately (don't batch). 3 attempts = 3 dated entries.
- **APPEND-ONLY ledger:** Can overwrite Status & "Left Off At" only. NEVER delete/overwrite Attempts, Context, or Done Criteria.
- Before session ends -> update Attempts entry (date, what tried, result), update "Left Off At" with specific resumption point.

**WHEN FIX WORKS:**
- Set status to "needs verification" (NEVER "done").
- **NEVER move to `docs/tasks/closed/`** - task stays in `open/` until user explicitly approves.
- After successful fix (code works + tests pass + committed) -> IMMEDIATELY ask: "This fix appears to be working. Want me to walk through the Done Criteria to close out this task?"

**ONLY USER CAN SAY A TASK IS COMPLETE.**

TASK FILE TEMPLATE:

```
## Task: [name]
## Status: not started | in progress | blocked | needs verification
## Goal: [one sentence max]
## Relevant Files:
- [only files this task touches, with brief note on what changes]
## Context:
[only decisions and findings relevant to THIS task -- not general project context]
## Done Criteria:
- [ ] [specific testable criterion]
- [ ] [specific testable criterion]
## Left Off At:
[exactly where work stopped -- be specific enough that a new session can resume without asking questions]
## Attempts:
- [date]: what was tried -> what happened -> result (worked/failed/partial)
```

---

## Critical Rules

### 1. NO MOCK DATA
> **WHY:** Wrong info destroys user trust. [CUSTOMIZE: Your product]'s value IS accuracy.

- External service fails -> return "Unable to retrieve [CUSTOMIZE: data type]"
- Model fails -> return "Unable to [CUSTOMIZE: process/analyze]"
- **NEVER** generate fake/fallback responses

### 2. .env IS SACRED
> **WHY:** Claude has modified .env before -> lost credentials and variables. Recovery is painful.

- **READ-ONLY** - never modify without explicit approval
- Missing var? Say so. **NEVER** create new `.env`

### 3. TEST BEFORE DECLARING COMPLETE
> **WHY:** Untested features cascade into broken systems.

- Run `[CUSTOMIZE: your test command, e.g., pytest tests/ -v -x]` before marking ANY task complete
- [CUSTOMIZE: Add frontend test command if applicable, e.g., cd frontend && npm test -- --watchAll=false]
- If tests fail -> task is NOT complete

### 4. ROOT CAUSE OVER BAND-AID
> **WHY:** Patches accumulate into unmaintainable systems. Fix the disease, not the symptom.

- If proper fix needs refactoring -> tell user, don't patch
- Band-aids are only acceptable when the user explicitly approves a temporary fix

### 5. VERIFY BEFORE PROCEEDING
> **WHY:** Continuing a plan that's hitting resistance compounds errors.

- Execute in small, verifiable steps
- On ANY failed verification -> STOP and reassess
- Never continue a plan hitting resistance

### [CUSTOMIZE] Add Your Project-Specific Rules Below

<!--
Add rules specific to your project. Each rule should have:
1. A clear name
2. A WHY block explaining consequences of breaking it
3. Specific do/don't instructions

Example format:

### 6. [RULE NAME]
> **WHY:** [What happened when this was violated -- concrete story]

- [Specific instruction]
- [Specific instruction]
- **NEVER** [specific prohibition]

Common project-specific rules to consider:

- Protected infrastructure (managed identity, deployment slots, CI/CD config)
- Data integrity (database schemas, product catalogs, migration files)
- Security boundaries (credentials in context, SAS URLs, API keys)
- No new endpoints / no endpoint sprawl
- Singleton services that must never be recreated
- Cache decorators that must be preserved
- Protected code sections that broke repeatedly
-->

---

## Constraints

- **Read code first** -- never propose edits without reading relevant files
- [CUSTOMIZE: Add project-specific constraints]

<!--
Examples of common constraints:

- **UI changes** -- require explicit user approval
- **No new endpoints** -- modify existing only, maintain backward compatibility
- **Singletons** -- never recreate [your singleton services]
- **Caching** -- preserve LRU decorators ([N]x speedup)
- **Data files** -- [file path] contains [N] records, never modify structure
- **Security** -- never include [credential type] in LLM context
-->

---

## Workflow
Follow the complete workflow in docs/WORKFLOW.md. Key rules:
- Always check docs/tasks/open/ at session start
- Task files are persistent memory -- read before acting
- Never set status to "done" -- only "needs verification"
- Attempts log is append-only, never overwrite
- End every session with: "Summarize what changed, test results, and what's left"
- Agent Teams: when task file shows "Execution Mode: agent-team", use delegate mode as lead, teammates report via messaging, lead owns task file exclusively, tag attempts by teammate role
- [CUSTOMIZE: Add language-specific rules, e.g., "Always activate venv before Python commands"]

## Hooks (Automated Enforcement)
Workflow rules are enforced by hooks at two levels:

### Global hooks (~/.claude/hooks/) -- apply to ALL projects:
- **SessionStart**: Injects workflow reminders on every new or resumed session
- **Stop**: Blocks stopping without a close-out summary (what changed, test results, what's left)
- **PostToolUse/Write|Edit**: Prevents setting task status to "done" and catches attempts log overwrites
- **TeammateIdle**: Requires agent team teammates to report completion summary before going idle

### Project hooks (.claude/hooks/) -- [CUSTOMIZE] per project:
- **PreToolUse/Bash**: [CUSTOMIZE: e.g., blocks Python commands without venv activation]
- **TaskCompleted**: [CUSTOMIZE: e.g., runs pytest before allowing task completion]

<!--
To set up hooks, see the hooks/ directory in the workflow-starter-kit for
ready-to-use hook scripts and configuration examples.
-->
