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

**MID-SESSION CHANGES (when task file updates are required):**
- **Scope changes** (approach pivot, architecture decision) -> update Context section immediately
- **Criteria changes** (new requirements, updated done criteria) -> update Done Criteria immediately
- **Failed approaches** -> append to Attempts immediately (date, what tried, result)
- **Before session ends** -> declare task file status in summary:
  - If updated: "Task file updated: docs/tasks/open/[filename].md"
  - If unchanged: "Task file unchanged -- no scope/criteria changes"
- The stop hook enforces the declaration (reminder); this rule defines when updates are required (enforcement)

**WHEN FIX WORKS:**
- Set status to "needs verification".
- **NEVER move to `docs/tasks/closed/`** - task stays in `open/` until user explicitly approves.
- After successful fix (code works + tests pass + committed) -> IMMEDIATELY ask: "This fix appears to be working. Want me to walk through the Done Criteria to close out this task?"
- **Close-out sequence (do ALL before attempting `mv`):**
  1. Walk through EVERY Done Criterion with the user -- mark each `[x]` only after user confirms
  2. Write retro entry in `docs/tasks/RETRO.md` (### [date] Task: task-name)
  3. Set `## Code Review:` field to `completed` or `not required`
  4. Move task file to `docs/tasks/closed/`
- A preflight hook checks all 3 conditions on `mv` and reports all failures at once.

**ONLY USER CAN SAY A TASK IS COMPLETE.**

TASK FILE TEMPLATE:

```
## Task: [name]
## Status: not started | in progress | blocked | needs verification
## Code Review: required | not required | in progress | completed
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
## Code Review Findings:
- [date]: [severity/category] [file:line] [finding] → [resolution] (fixed/wontfix/deferred)
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

### 6. IMPLEMENT MEANS EXECUTE
> **WHY:** Claude spent entire sessions writing plans for 4-line code changes, producing zero edits.

- "implement", "apply", "make these changes", or specific code edits -> **execute immediately**, no plan mode
- "explore", "investigate", "plan", "design", or "figure out" -> plan first, then propose
- Ambiguous -> ask: "Should I implement this now or explore first?"
- Do not write a plan document when the user has already described the exact changes to make

### 7. NO GOD OBJECTS
> **WHY:** The 500-line cap is a smoke alarm, not a fire code.
> The real rule is "one file, one reason to change" — but humans
> argue about that forever, so we use line count as a dumb-but-
> measurable proxy. When a file crosses 500 lines, it's almost
> always because two responsibilities snuck in. The cap forces
> the split conversation that should have happened at line 200
> but didn't, because Claude doesn't feel the "and" the way a
> senior engineer does.

- File budget: 500 lines maximum
- Function budget: 50 lines maximum
- One class per file

### 8. RULE OF THREE
> **WHY:** Premature shared modules become god objects too.
> Don't extract a "shared" module until 3 real callers exist.

- Don't extract until 3 callers
- Three similar lines beats a premature abstraction

### 9. ONE CONCEPT PER COMMIT
> **WHY:** God objects grow from 12 unrelated changes pretending
> to be one feature. Tiny commits force naming.

- One conceptual change per commit
- If you can't name what changed in 6 words, split the commit

### [CUSTOMIZE] Add Your Project-Specific Rules Below

<!--
Add rules specific to your project. Each rule should have:
1. A clear name
2. A WHY block explaining consequences of breaking it
3. Specific do/don't instructions

Example format:

### 7. [RULE NAME]
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
- End every session with the `/stop` skill summary (4 required sections below)
- Code review is required before close-out for any task that modifies code. Follow the plan/explore/review/execute sub-loop. Set "Code Review: not required" only for documentation-only or non-code tasks.
- Agent Teams: when task file shows "Execution Mode: agent-team", use delegate mode as lead, teammates report via messaging, lead owns task file exclusively, tag attempts by teammate role
- [CUSTOMIZE: Add language-specific rules, e.g., "Always activate venv before Python commands"]

### Session-End Summary Format (enforced by stop hook)
Every session MUST end with these 4 sections. The stop hook blocks exit until all pass:
1. **What changed** -- list every file modified with extensions (e.g., `executor.py`, `SKILL.md`)
2. **Test results** -- include numeric counts (e.g., "560 passed, 0 failed"), not just "tests pass"
3. **What's left** -- use phrasing like "what's left", "next steps", or "nothing remaining"
4. **Task file status** -- "Task file updated: docs/tasks/open/[name].md" or "Task file unchanged"

Never provide a vague or abbreviated summary. The stop hook WILL reject it. Use `/stop` to generate a compliant summary.

## Hooks (Automated Enforcement)
Workflow rules are enforced by hooks at two levels:

### Global hooks (~/.claude/hooks/) -- apply to ALL projects:
- **SessionStart**: Injects workflow reminders on every new or resumed session
- **Stop**: Blocks stopping without a detailed close-out summary (every file modified, test counts, specific next steps)
- **PostToolUse/Write|Edit**: Catches attempts log overwrites
- **PreToolUse/Bash**: Combined close-out preflight — checks done criteria, retro entry, and code review in one pass
- **TeammateIdle**: Requires agent team teammates to report completion summary before going idle

### Project hooks (.claude/hooks/) -- [CUSTOMIZE] per project:
- **PreToolUse/Bash**: [CUSTOMIZE: e.g., blocks Python commands without venv activation]
- **PreToolUse/Write|Edit|MultiEdit**: filesize-guard blocks writes that push files past `MAX_FILE_LINES` (default 500); files in `.claude/filesize-baseline.txt` are grandfathered under shrink-or-equal
- **TaskCompleted**: [CUSTOMIZE: e.g., runs pytest before allowing task completion]

<!--
To set up hooks, see the hooks/ directory in the workflow-starter-kit for
ready-to-use hook scripts and configuration examples.
-->

---

## Architect Questions to Ask Constantly

1. Where does this belong, and why there?
2. What else lives in that file/module? Are they really the same
   kind of thing? **The "and" test:** describe the file in one
   sentence with no "and". If you can't, two responsibilities
   are sharing one room.
3. What changes together with this?
4. If [business rule] changes, how many files have to change?
   **Sweet spot: 2–4 files for a typical change.** 14 files →
   boundaries are too granular. 1 file that's 2000 lines →
   boundaries are too coarse.
5. Is anything else doing something similar? Should they share?
6. What's the simplest version of this? Are we building more
   than we need?
7. Can you explain this without using the words "utils,"
   "helper," "manager," or "handler"?
8. If a new engineer joined tomorrow, which file would confuse
   them most? **The 60-second test:** can they load this file's
   purpose in 60 seconds? If they're scrolling for 10 minutes,
   split.

---

## Vocabulary

- **Module** — A file (or directory of files) that exposes a single concept to the rest of the codebase.
- **Function** — A named unit of work with explicit inputs, an explicit return, and ideally no hidden state.
- **Class** — A bundle of related state plus the operations that act on it; lives in its own file when non-trivial.
- **Dependency** — Something a module needs from elsewhere to do its job (another module, a service, a piece of config).
- **Contract / Interface** — The promise a module makes to its callers about inputs, outputs, and side effects, separate from how it fulfills that promise.
- **Coupling** — How much one module's internals must change when another module changes. Lower is better.
- **Cohesion** — How tightly the things inside one module relate to each other. Higher is better.
- **Side effect** — Anything a function does beyond returning a value (writes a file, sends a request, mutates shared state). Make these explicit.
