---
name: plan-review
description: Pre-execution self-check to validate a plan before writing any code
---

# Plan Review

A 6-point checklist to validate a plan before execution begins. Catches over-engineering, missed criteria, unverified assumptions, and scope creep.

## When to Run

Before writing any code, after a plan exists. This is the gate between Phase 3 (Review) and Phase 4 (Execute) in the development workflow.

## Checklist

Review the plan against these 6 questions:

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

## Decision Output

- **All 6 pass** — Proceed with execution as planned.
- **Items 3, 5, or 6 fail** — Simplify first. Reduce scope, reuse existing code, remove unnecessary abstractions. Then re-check.
- **Items 1, 2, or 4 fail** — Flag for human review before proceeding. Missing criteria, violated constraints, or unverified assumptions need user input to resolve.
