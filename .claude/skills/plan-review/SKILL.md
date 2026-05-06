---
name: plan-review
description: Pre-execution self-check to validate a plan before writing any code
---

# Plan Review

An 8-point checklist to validate a plan before execution begins. Catches over-engineering, missed criteria, unverified assumptions, scope creep, misplacement, and size-budget violations.

## When to Run

Before writing any code, after a plan exists. This is the gate between Phase 3 (Review) and Phase 4 (Execute) in the development workflow.

## Checklist

Review the plan against these 8 questions:

1. **Does the plan address ALL success criteria from the task file?**
   Map each success criterion to a specific part of the plan. Any criterion without a matching plan step is a gap.

2. **Does the plan violate any stated constraints?**
   Check constraints from both the task file and project-level rules. A plan that touches forbidden files, adds forbidden endpoints, or bypasses stated limits fails here.

3. **Is there a simpler approach that meets the same criteria?**
   If the plan introduces new abstractions, new files, or new patterns — could the same outcome be achieved by modifying existing code? Fewer moving parts is better.

4. **Are there assumptions about the codebase that haven't been verified by reading code?**
   Any plan step that says "this probably works like X" or "this file likely contains Y" is an unverified assumption. Read the code first.

5. **Does the plan touch files outside the stated scope?**
   Compare the plan's file list against the task file's "Relevant Files" section. Unexpected files signal scope creep.

6. **Are there existing functions or utilities that could be reused instead of writing new code?**
   Search for existing helpers, services, or patterns that already solve part of the problem. Duplication is a sign the plan needs revision.

7. **Where does this belong, and why there? If new module, what's its single responsibility and contract?**
   Name the file or module the new code lands in. State why that location — what concept it shares with what's already there. For new modules, write the one-sentence single-responsibility description (no "and") and the contract (inputs, outputs, side effects). Vague placement ("a util", "a helper") is a fail.

8. **Will this push any file past the size budget? What gets extracted first?**
   Project budget is 500 LOC per file. For each file the plan modifies, estimate post-edit line count. If any file would cross 500 (or grow further past it for grandfathered files), name what gets extracted first — which functions or sections move to a new file, and what that new file's single responsibility is. "We'll deal with it later" is a fail.

## Decision Output

- **All 8 pass** — Proceed with execution as planned.
- **Items 3, 5, 6, 7, or 8 fail** — Simplify first. Reduce scope, reuse existing code, remove unnecessary abstractions, fix placement, or extract before exceeding the size budget. Then re-check.
- **Items 1, 2, or 4 fail** — Flag for human review before proceeding. Missing criteria, violated constraints, or unverified assumptions need user input to resolve.
