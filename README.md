# AI-Assisted Development Workflow Starter Kit

A battle-tested system for getting reliable, repeatable results from Claude Code (CLI) and Claude AI (browser). Built over 60+ tasks on a production codebase.

---

## 1. What Is This / Why

Claude Code forgets everything between sessions. Every time you start a new conversation, it starts from zero -- no memory of what it tried, what failed, or where it left off. This workflow solves that problem with a simple insight: **declarative, not imperative.** Instead of giving Claude step-by-step instructions (which break when anything unexpected happens), you give it persistent context: task files that track state across sessions, a CLAUDE.md file that encodes project rules and their consequences, automated hooks that enforce discipline, and a retrospective log that captures lessons learned. The result is an AI assistant that picks up exactly where it left off, never retries failed approaches, and improves over time. This starter kit packages the entire system so you can drop it into any project in five minutes.

---

## 2. Quick Start (5 Minutes)

### Prerequisites

- **Claude Code CLI** installed and authenticated ([install guide](https://docs.anthropic.com/en/docs/claude-code))
- **Claude AI browser access** at [claude.ai](https://claude.ai) (used for planning and review phases)

### Steps

**1. Run the installer from the starter kit directory:**

```bash
cd ~/workflow-starter-kit
./install.sh
```

This copies global hooks to `~/.claude/hooks/`, merges hook registrations into `~/.claude/settings.json`, and creates the `docs/tasks/` directory structure in your current project.

**2. Customize CLAUDE.md in your project:**

Copy the template and edit it for your project:

```bash
cp ~/workflow-starter-kit/templates/CLAUDE.md ./CLAUDE.md
```

Edit the file to add your project-specific rules, constraints, and protected code sections. Keep the Task Management section verbatim -- it is the universal contract between you and Claude Code. Add your own Critical Rules with WHY blocks explaining consequences.

**3. Create your first task file:**

```bash
mkdir -p docs/tasks/open docs/tasks/closed
```

Then ask Claude Code:

```
Create a task file in docs/tasks/open/ for: [describe what you want to accomplish]
```

Claude Code will create the file from the template, explore the codebase, and generate a plan. You are now in the workflow.

---

## 3. The Full Workflow Loop

Most tasks follow a seven-phase cycle. You loop between Claude AI (browser) for thinking and Claude Code (CLI) for doing.

```
                        YOU
                         |
                         v
    +------------------------------------+
    |  Phase 1: PLAN (Claude AI browser) |
    |  Define success criteria, tests,   |
    |  constraints. Get a prompt to send  |
    |  to Claude Code.                   |
    +------------------------------------+
                         |
                         v
    +------------------------------------+
    |  Phase 2: EXPLORE (Claude Code)    |
    |  Check tasks, explore codebase,    |
    |  generate plan. Log to task file.  |
    +------------------------------------+
                         |
                         v
    +------------------------------------+
    |  Phase 3: REVIEW (Claude AI)       |
    |  Challenge assumptions, simplify,  |
    |  improve approach. Refine plan.    |
    +------------------------------------+
                         |
                         v
    +------------------------------------+
    |  Phase 4: EXECUTE (Claude Code)    |
    |  Implement changes. Log every      |
    |  attempt immediately to task file. |
    +------------------------------------+
                         |
                         v
    +------------------------------------+
    |  Phase 5: CODE REVIEW              |
    |  (Claude AI + Claude Code)         |
    |  Plan review scope with Claude AI. |
    |  Execute review with Claude Code.  |
    |  Log findings. Fix issues.         |
    |  Skip if "not required."           |
    +------------------------------------+
                         |
                         v
    +------------------------------------+
    |  Phase 6: VERIFY (You + Claude)    |
    |  Walk Done Criteria one by one.    |
    |  You confirm each checkbox.        |
    +------------------------------------+
                         |
                         v
    +------------------------------------+
    |  Phase 7: CLOSE-OUT (You)          |
    |  Approve task. Add retro entry.    |
    |  Move task to closed/.             |
    +------------------------------------+
```

**Typical flow:** Phase 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7.

**Common variations:**
- Phase 4 reveals a wrong assumption -> bounce back to Phase 3 for re-planning
- Phase 5 code review finds issues -> fix them, return to Phase 4 for another attempt
- Phase 6 fails a verification criterion -> return to Phase 4 for rework
- Simple bug fix -> skip Phase 3 and go straight from Phase 2 to Phase 4
- Documentation-only task -> set "Code Review: not required" and skip Phase 5

The key discipline: every phase produces an artifact. Plans are written down. Attempts are logged. Criteria are checked off. Nothing lives only in your head or in a chat window that will disappear.

---

## 4. Starter Prompts

These are copy-paste prompts for starting Claude AI (browser) sessions. Use them every time you kick off a new phase that starts in the browser.

### Phase 1: Task Planning Prompt

Copy this into a new Claude AI chat when you have a feature or bug to work on:

```markdown
You are a senior dev planning partner. Your job is to help me define
tasks before I send them to Claude Code for implementation.

Rules:
- No code. Planning only.
- Push for robust, long-term solutions — no band-aids.
- Challenge my assumptions. Find gaps in my thinking.
- Be a critic, not a yes-man.

Together we define:
1. Success criteria — specific, testable outcomes
2. Tests — what proves it works?
3. Constraints — what should Claude Code NOT do?
4. Execution mode — single agent or agent team? (Team only if zero
   file overlap)
5. Code review scope — required after every code change

Your output is a declarative prompt I paste directly into Claude Code.
Frame as outcomes, not step-by-step instructions.

Additional responsibilities:
- If a task has 3+ phases, split into separate task files
- Flag parallel work — identify agent team candidates with zero file
  overlap and explicit file ownership
- Always include an explore phase before implementation for non-trivial
  changes
- Probe edge cases, failure modes, missing steps, implicit assumptions,
  dependency risks, and rollback paths before greenlighting
- Only say "execute" after exhaustive scrutiny
- After code review, determine what's next from the roadmap
```

### Phase 5: Code Review Planning Prompt

Copy this into a new Claude AI chat after Phase 4 execution completes and you're ready to plan the code review:

```markdown
You are my code review partner. I implement features in Claude Code, 
then bring you the results. Your job:

1. **Challenge the implementation, not just the tests.** Tests passing 
   doesn't mean the code is correct. Probe whether the change actually 
   solves the problem and whether it introduces new problems.

2. **Ask hard questions before writing the review prompt.** Identify 
   assumptions, edge cases, and failure modes from the summary alone. 
   Make me answer them. This often catches issues cheaper than a 
   line-by-line review.

3. **Write review prompts for Claude Code.** Structured prompts with 
   specific files, specific dimensions (architecture, edge cases, error 
   handling, security, performance, test coverage), and a findings format. 
   Split into agents by file ownership for large changes.

4. **Scrutinize the review results.** A grep-based review that confirms 
   removals are clean is not a full review. Push for a second pass on 
   replacement correctness, caller-side impacts, and behavioral changes 
   under failure.

5. **Gate execution.** Don't say "execute" until the plan survives 
   exhaustive scrutiny. Every gap found before execution saves 10x.

6. **Write fix plans when review finds issues.** Investigation-first 
   (understand before changing), specific file/line targets, ordered 
   execution, verification steps.

Findings format:
- [date]: [severity/category] [file:line] [finding] → [resolution]
- Severity: critical, major, minor, nit
- Categories: bug, edge-case, security, performance, architecture, 
  style, test-gap

Rules:
- No code. Planning and review only.
- Substance over style — bugs and edge cases matter more than formatting.
- If a review comes back clean, ask what it DIDN'T check.
- Default to "investigate first" before any fix.
```
---

## 5. Task Files -- Persistent Memory

Claude Code has no memory between sessions. When you start a new conversation, it knows nothing about what happened before. Task files solve this completely.

### The Template

```markdown
## Task: [descriptive name]
## Status: not started | in progress | blocked | needs verification
## Code Review: required | not required | in progress | completed
## Goal: [one sentence -- the outcome, not the approach]

## Relevant Files:
- [only files this task touches, with brief note on what changes]

## Context:
[decisions and findings relevant to THIS task -- not general project context]

## Done Criteria:
- [ ] [specific testable criterion]
- [ ] [specific testable criterion]

## Left Off At:
[exactly where work stopped -- specific enough to resume cold]

## Attempts:
- [date]: what was tried -> what happened -> result (worked/failed/partial)

## Code Review Findings:
- [date]: [severity/category] [file:line] [finding] → [resolution] (fixed/wontfix/deferred)
```

### Rules That Make It Work

**Status is never "done."** Claude Code sets status to "needs verification" when it believes the work is complete. Only you can close a task, after walking through every Done Criterion. This prevents premature declarations of victory.

**Attempts log is append-only.** Every attempt gets logged immediately after it is tried -- not batched at session end. Never delete or overwrite previous entries. If Claude tried three things in one session, there are three separate dated entries. This creates a complete history that prevents retrying failed approaches.

**"Left Off At" must be specific enough to resume cold.** Not "working on the bug" but "Modified `src/services/auth.py` line 312, test_login passes but test_session fails on assertion at line 45 -- need to check if the token response includes the expected `refresh_token` field." A new session should be able to resume without asking any questions.

**Only the user can close a task.** Claude proposes that work is done. You verify. You approve. You say "close it out." This is non-negotiable.

### What This Looks Like In Practice

Session 1 creates the task, explores, tries an approach. It fails. Claude logs the attempt and updates "Left Off At."

Session 2 (hours or days later) reads the task file, sees the failed attempt, sees "Left Off At," and picks up from exactly that point with a different approach. No repeated work. No re-exploration. No "what were we doing again?"

---

## 6. CLAUDE.md -- Project Instructions

CLAUDE.md is a file in your project root that Claude Code reads at the start of every session. It is your contract with the AI -- the rules it must follow, the mistakes it must not repeat, and the constraints it must respect.

### Anatomy

**Task Management section (universal -- copy verbatim from the template).** This section defines the workflow contract: check for existing tasks, create task files before working, log attempts immediately, never set status to "done." Every project uses the same section.

**Critical Rules with WHY blocks.** This is the most important pattern in the entire workflow. Each rule has a `> **WHY:**` block that explains the *consequence* of breaking it -- not just the rule itself.

```markdown
### 2. .env IS SACRED
> **WHY:** Claude has modified .env before -- lost credentials and variables.
> Recovery is painful.

- **READ-ONLY** - never modify without explicit approval
- Missing var? Say so. **NEVER** create new `.env`
```

The WHY block is the secret sauce. Claude Code is good at following rules, but it is much better at following rules when it understands what goes wrong if it breaks them. "Don't modify .env" is a rule. "Don't modify .env because we lost all our credentials last time and it took two days to recover" is a rule Claude will never break.

**Constraints section.** Short, scannable list of things Claude must not do: no new endpoints, no UI changes without approval, never recreate singletons, preserve caching decorators.

**Workflow and hooks references.** Pointers to the workflow doc and hook locations so Claude knows the enforcement system exists.

### Building Your Own CLAUDE.md

Start with the template from this starter kit. Keep the Task Management section unchanged. Then add your own rules by asking: "What has Claude (or any developer) broken in this project that was painful to fix?" Each of those incidents becomes a Critical Rule with a WHY block.

You will build up rules over time. Every painful mistake becomes a permanent guardrail.

---

## 7. Hooks -- Automated Enforcement

Rules in CLAUDE.md work because Claude reads them. Hooks work even when Claude does not read them. They are shell scripts that fire on specific Claude Code events and can block actions that violate the workflow.

### Hook Reference

| Hook | Trigger | What It Does | Location |
|------|---------|--------------|----------|
| `session-start` | Session starts or resumes | Injects workflow rules reminder and recent retro entries | Global |
| `stop-require-summary` | Agent stops | Blocks stopping without a detailed summary (every file modified, test counts, specific next steps) | Global |
| `guard-task-status` | Write/Edit to task files | Prevents setting status to "done" or "complete" -- only "needs verification" allowed | Global |
| `require-retro-before-close` | `mv` command (open -> closed) | Requires a retro entry in RETRO.md before allowing task file to move to closed/ | Global |
| `require-review-before-close` | `mv` command (open -> closed) | Requires code review to be "completed" or "not required" before allowing task close | Global |
| `teammate-require-summary` | Teammate goes idle | Requires completion summary (files changed, test results) from agent team teammates | Global |
| `require-venv` | Bash command | Blocks Python/pip/pytest commands that do not activate virtualenv first | Project |
| `task-require-tests` | Task completion | Runs the test suite before allowing a task to be marked complete -- fails block completion | Project |

### Global vs Project Hooks

**Global hooks** live in `~/.claude/hooks/` and are registered in `~/.claude/settings.json`. They enforce workflow rules that apply to every project: task file discipline, session summaries, retro logging. Install these once and they work everywhere.

**Project hooks** live in `.claude/hooks/` inside your project and are registered in `.claude/settings.json` (project-level). They enforce project-specific rules: virtualenv activation for Python projects, test suite execution, linting requirements. Customize these per project and per language.

### How Hooks Work

Hooks are shell scripts that receive JSON on stdin with context about the action being performed. They can:

- **Exit 0** -- allow the action to proceed
- **Exit 2 + write to stderr** -- block the action and show a message to Claude Code explaining why

Example: the `guard-task-status` hook reads the content being written, checks if it contains `Status: done`, and blocks the write with a message telling Claude to use "needs verification" instead.

### Customizing Project Hooks

The two project hooks in this starter kit are examples. Replace them with whatever your project needs:

- **Python project:** `require-venv.sh` (included) and `task-require-tests.sh` using pytest (included)
- **Node.js project:** Replace with a hook that runs `npm test` or `npx jest`
- **Go project:** Replace with a hook that runs `go test ./...`
- **Any project:** Add linting hooks, type-checking hooks, or build verification hooks

---

## 8. Skills -- Workflow Intelligence

Skills are markdown files in `.claude/skills/` that give Claude Code specialized domain knowledge for specific workflow activities. While CLAUDE.md defines project rules and constraints, skills teach Claude *how* to perform specific workflow processes -- creating task files, running retrospectives, validating plans, and following the development loop.

### Included Skills

| Skill | Location | Purpose |
|-------|----------|---------|
| **workflow** | `.claude/skills/workflow/SKILL.md` | The 7-phase development loop from plan to close-out |
| **task-manager** | `.claude/skills/task-manager/SKILL.md` | Task file lifecycle: create, update, resume, complete |
| **plan-review** | `.claude/skills/plan-review/SKILL.md` | 6-point pre-execution validation checklist |
| **retro** | `.claude/skills/retro/SKILL.md` | Retrospective entry format and quality guidelines |

### How Skills Work

Claude Code automatically reads skill files when it needs domain knowledge for a matching activity. You do not need to reference them explicitly -- they are available as context whenever relevant.

### Customizing Skills

- **Edit existing skills** to match your team's workflow terminology or add project-specific examples
- **Add new skills** by creating a new directory under `.claude/skills/` with a `SKILL.md` file
- Each skill file starts with YAML frontmatter (`name` and `description`) followed by markdown content

---

## 9. Code Review -- Mandatory Before Close-Out

Every task that modifies code must go through a code review before it can be closed out. This is enforced by the `require-review-before-close` hook -- you literally cannot move a task file to `docs/tasks/closed/` without it.

### Why This Exists

Skipping code review is the number one way bugs compound. "I'll review it later" never happens. By making code review a first-class phase (Phase 5) with its own sub-loop and hook enforcement, it becomes part of the workflow rather than an afterthought.

### The Code Review Sub-Loop

Code review follows the same plan/explore/review/execute pattern as the main workflow:

1. **Plan the review (Claude AI browser):** Bring the recent commits and changes to Claude AI. Together define review scope -- architecture, edge cases, error handling, security, performance, test coverage. Claude AI produces a review prompt, splitting by agents if the changes are large.
2. **Explore for review (Claude Code CLI):** Send the review prompt to Claude Code. It examines the changes and generates a review plan.
3. **Refine the review plan (Claude AI browser):** Bring the review plan back to Claude AI. Challenge it -- missing edge cases? Over-focusing on style vs substance?
4. **Execute the review (Claude Code CLI):** Run the review. Log every finding in the task file's Code Review Findings section. Fix issues found. Re-run tests.

### Task File Fields

Two new fields in the task file:

```markdown
## Code Review: required | not required | in progress | completed
```

- **required** (default): Code review must happen before close-out
- **not required**: Explicitly opted out -- only for documentation-only or non-code tasks
- **in progress**: Code review sub-loop is active
- **completed**: All findings addressed, ready for close-out

```markdown
## Code Review Findings:
- [date]: [severity/category] [file:line] [finding] → [resolution] (fixed/wontfix/deferred)
```

### Opting Out

Some tasks genuinely don't need code review: documentation updates, README changes, config tweaks that don't affect runtime behavior. Set `## Code Review: not required` during Phase 1 planning or at any point with user approval. The hook accepts both "completed" and "not required" as valid states for close-out.

---

## 10. RETRO.md -- Learning Across Tasks

RETRO.md is an append-only log of lessons learned across all tasks. It lives at `docs/tasks/RETRO.md` in your project.

### Why It Matters

Without a retro log, the same mistakes repeat across tasks. Claude Code does not remember Session 5's lesson when it starts Session 20. RETRO.md fixes this: the `session-start` hook reads the last 10 entries and injects them into Claude's context at the beginning of every session.

This means Claude starts every session knowing the most recent lessons from your project -- even across completely different tasks.

### Entry Template

```markdown
### [YYYY-MM-DD] Task: [task name]
- **What worked:** [approaches worth repeating]
- **What broke:** [failures to avoid next time]
- **Workflow friction:** [process issues, not code issues -- or "None"]
- **Pattern:** [generalizable lesson for future tasks]
```

### How It Gets Written

When you say "close it out" on a completed task, Claude Code appends a retro entry before moving the task file to `docs/tasks/closed/`. The `require-retro-before-close` hook enforces this -- it blocks the `mv` command if no matching entry exists in RETRO.md.

### What Makes a Good Entry

The **Pattern** field is the most valuable. It should be a generalizable lesson that applies beyond the specific task:

- Good: "When verifying unused Python modules, check BOTH absolute and relative import patterns."
- Bad: "Fixed the import bug in chat_service.py."

Good patterns become institutional knowledge that compounds over time.

---

## 11. Settings Files

Claude Code uses two settings files that control hooks, environment variables, and other configuration.

### Global Settings (`~/.claude/settings.json`)

Applies to all projects. Contains:
- Hook registrations for global hooks (session-start, stop-require-summary, guard-task-status, require-retro-before-close, teammate-require-summary)
- Environment variables (e.g., enabling agent teams)
- Login and authentication preferences

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

### Project Settings (`.claude/settings.json`)

Lives in your project directory. Contains:
- Hook registrations for project-specific hooks (require-venv, task-require-tests)
- Project-specific environment overrides

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/require-venv.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "TaskCompleted": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/task-require-tests.sh",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

### Hook Event Types

| Event | When It Fires | Use For |
|-------|---------------|---------|
| `SessionStart` | Session starts (`startup`) or resumes (`resume`) | Injecting context, reminders |
| `Stop` | Agent is about to stop | Requiring close-out summaries |
| `PreToolUse` | Before a tool is invoked (matcher filters by tool name) | Blocking dangerous commands |
| `PostToolUse` | After a tool is invoked (matcher filters by tool name) | Validating outputs |
| `TaskCompleted` | A task is marked complete | Running tests, checks |
| `TeammateIdle` | An agent team teammate goes idle | Requiring status reports |

---

## 12. Advanced: Agent Teams

Agent teams let multiple Claude Code instances work in parallel on different parts of a task. This is powerful but adds coordination overhead. Use it only when the math works out.

### When to Use (All Four Must Be True)

- [ ] Work spans **multiple files** with clear ownership boundaries
- [ ] Tasks can run **independently in parallel** (no sequential dependencies)
- [ ] Each piece produces a **clear deliverable** (a function, a test file, a component)
- [ ] Time savings from parallelization **outweigh coordination overhead**

**Quick check:** Can you draw file-ownership lines with zero overlap? Yes -> candidate for agent teams. No -> use single agent.

### How It Works

1. **Lead agent** runs in delegate mode (coordinates only, does not write code)
2. **Teammates** (2-4) each own specific files and a specific objective
3. Lead creates a shared task list for coordination
4. Teammates report progress via messaging
5. Lead owns the task file exclusively and logs all teammate results

### Task File Logging for Teams

The lead agent is the only writer to the task file. Teammate results are tagged:

```markdown
## Attempts:
- 2026-02-06 [Teammate: API]: Modified router.py lines 280-315.
  Changed mapping to match database schema. pytest passed (5/5).
  -> Result: worked

- 2026-02-06 [Teammate: Frontend]: Updated Results.jsx column headers.
  Manual test: query returns correct columns. Console: no errors.
  -> Result: worked

- 2026-02-06 [Lead]: Both teammates completed. Integration test pending.
  -> Result: partial (integration not yet tested)
```

### Shutdown Sequence

1. All teammates send final completion summaries to lead
2. Lead logs all summaries to the task file
3. Lead sends shutdown request to each teammate (teammate confirms)
4. Lead cleans up shared team resources
5. Lead updates task file status and "Left Off At"

---

## 13. Advanced: Ralph Autonomous Loop

For fully autonomous multi-step execution, this workflow integrates with the Ralph system. Ralph creates a `prd.json` with user stories from an interview, then loops automatically through implementation.

### When to Use

- Multi-story features where each story has clear acceptance criteria
- Work that benefits from autonomous execution with periodic checkpoints
- Tasks where you want Claude to run unattended for multiple cycles

### How It Works

1. Run `/interview` or ask clarifying questions to define the feature
2. Create `prd.json` with user stories and acceptance criteria
3. Review stories with the user
4. Run: `~/ralph-system/ralph-loop.sh 20` (runs up to 20 cycles)

### Rules

- Never write feature code without `prd.json` existing
- Never skip the interview step for complex features
- Never mark stories as passed without meeting ALL acceptance criteria
- Always update CLAUDE.md with patterns and gotchas discovered during the loop

See `~/ralph-system/` for full documentation.

---

## 14. Tips and Lessons Learned

These are generalized from real retrospective entries accumulated over 60+ tasks.

**Extracting code from large classes.** Verify statelessness first -- confirm extracted methods have no hidden dependencies on instance state. Use AST parsing to verify method counts rather than manual counting. When deleting methods from the source class, work bottom-to-top to avoid line number drift during sequential edits.

**Verifying unused modules.** When checking whether a Python module is safe to delete, search for BOTH absolute import patterns (`from src.x.y import Z`) AND relative import patterns (`from ..y import Z`, `from .y import Z`). Relative imports are invisible to absolute-path searches and are common in deeply nested packages.

**CI pipeline first runs.** The first CI run in a new pipeline will catch every implicit dependency that works locally but fails in a clean environment -- globally installed packages, stale virtualenvs, OS-level libraries. Treat the first failure as expected, not alarming.

**Shell hooks that parse markdown.** Test with empty and missing files first. Edge cases in grep exit codes (exit 1 on zero matches vs exit 0 on matches) cause subtle bugs. Pattern matching inside HTML comments can produce false positives if you are not careful with anchoring.

**Testing PreToolUse hooks.** Hooks that match on command content will fire on test invocations too. If your test command contains the pattern the hook is looking for, the hook will block your test. Plan for this by testing from directories where the matched file does not exist, or by invoking the script directly with stderr redirection.

**Replacing factory imports with DI.** When switching from factory function imports to dependency injection container resolution, update ALL test fixtures that patch the old factory names in the same commit. Stale mock patches are the most common source of test failures after DI migrations.

**Broad .gitignore patterns.** Patterns like `test_*.py` in `.gitignore` will block legitimate test files in subdirectories. Scope patterns to root-only (`/test_*.py`) to avoid blocking files in `tests/` or other nested directories. Use `git check-ignore -v <file>` to diagnose when `git add` unexpectedly fails.

**Session discipline.** Start every session with "Check docs/tasks/open first." End every session with what changed, test results, and what is left. This takes 30 seconds and prevents hours of confusion in the next session.

**Declarative over imperative.** Tell Claude what the result should be, not how to get there. "Make this test pass" is better than a 10-step implementation plan. Claude is good at figuring out the how -- but only when you clearly define the what.

**WHY blocks compound.** Every time something breaks, add a rule with a WHY block. After a few months, your CLAUDE.md becomes a comprehensive guardrail that prevents entire categories of mistakes. The investment pays off exponentially.

---

## File Structure Reference

```
workflow-starter-kit/
|-- README.md                          # This file
|-- install.sh                         # Installer script
|
|-- templates/
|   |-- CLAUDE.md                      # CLAUDE.md template for new projects
|   |-- task-file.md                   # Task file template
|   |-- RETRO.md                       # RETRO.md template with entry format
|   +-- WORKFLOW.md                    # Full workflow reference doc
|
|-- hooks/
|   |-- global/                        # Hooks for ~/.claude/hooks/
|   |   |-- session-start.sh           # Inject workflow rules + retro entries
|   |   |-- stop-require-summary.sh    # Block stop without close-out summary
|   |   |-- guard-task-status.sh       # Prevent status = "done"
|   |   |-- require-retro-before-close.sh  # Require retro before task close
|   |   |-- require-review-before-close.sh # Require code review before task close
|   |   +-- teammate-require-summary.sh    # Require teammate completion summary
|   |
|   +-- project/                       # Example hooks for .claude/hooks/
|       |-- require-venv.sh            # Block Python without venv (Python example)
|       +-- task-require-tests.sh      # Run tests before task completion
|
|-- .claude/
|   +-- skills/
|       |-- task-manager/
|       |   +-- SKILL.md                   # Task file lifecycle management
|       |-- workflow/
|       |   +-- SKILL.md                   # 7-phase development loop
|       |-- plan-review/
|       |   +-- SKILL.md                   # Pre-execution validation checklist
|       +-- retro/
|           +-- SKILL.md                   # Retrospective entry format
|
+-- settings/
    |-- global-settings.json           # Example ~/.claude/settings.json
    +-- project-settings.json          # Example .claude/settings.json
```

---

## Getting Help

- **Workflow questions:** Re-read this README and the `templates/WORKFLOW.md` reference
- **Hook not firing:** Check that the hook is registered in the correct settings.json (global vs project) and that the script is executable (`chmod +x`)
- **Task file confusion:** The task file is the source of truth. When in doubt, read the task file. If the task file is wrong, fix the task file.
- **Claude not following rules:** Add a WHY block to the rule in CLAUDE.md. Explain the consequence. Claude follows rules much more reliably when it understands what goes wrong.
