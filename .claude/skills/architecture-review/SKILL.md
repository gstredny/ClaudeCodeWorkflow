---
name: architecture-review
description: Use after implementing a feature or refactor with architect-mode-driven decisions; when reviewing a PR for structural fit (not just correctness); when a file is growing fast or accumulating responsibilities; or when an engineer says "this works but feels wrong"
---

# Architecture Review

Reviews implemented code against the structural decisions made during architect-mode. Catches drift between the stated plan and the actual placement, naming, and coupling.

## When to Run

- Immediately after architect-mode-driven implementation, before code review for correctness.
- During PR review when you want to evaluate structure, not just behavior.
- When a module crosses a size threshold (e.g., 400 LOC, 10 exported names) and you suspect it's accumulating unrelated work.

If you're reviewing for bugs, security, or test coverage, use a regular code-review skill instead. **This skill is structure-only.**

## The 5 Structural Checks

For each modified file in the diff, answer:

1. **Did any file grow past its size budget?**
   - Default budget: 500 LOC per file, matching the filesize-guard hard cap. If a file genuinely needs to exceed this, add it to `.claude/filesize-baseline.txt` AND document the exception in `ARCHITECTURE.md` with a written justification.

2. **Did any class gain a responsibility unrelated to its current name?**
   - A class named `OrderRepository` that now also sends emails has drifted.
   - If yes: extract the new responsibility or rename the class.

3. **Should any new code have been a new module?**
   - If a new function in an existing file would be more discoverable, more testable, or more reusable in its own module, it should be one.
   - If yes: extract.

4. **Are any names vague?**
   - Red list: `utils`, `helper`, `manager`, `handler`, `process_*`, `handle_*`, `do_*`, anything ending in `_2` or `_v2` without a migration plan.
   - If yes: rename to describe the actual responsibility.

5. **Any new circular dependencies?**
   - Trace the import graph for the changed files. Module `A → B → A` is always a structural smell.
   - If yes: invert the dependency or extract a shared interface.

## Output Format

Log every finding in the task file's `## Code Review Findings:` section, using the same format as the standard code review:

```
## Code Review Findings:
- [date]: [severity/category] [file:line] [finding] → [resolution] (fixed/wontfix/deferred)
```

Examples:
- `2026-05-05: structure billing/invoices.py:42 helper function "calculate_tax" duplicates logic in pricing/tax.py:18 → moved to pricing/tax.py and imported (fixed)`
- `2026-05-05: naming services/data_handler.py:1 "DataHandler" hides what it owns; rename to InvoiceExporter → renamed (fixed)`
- `2026-05-05: placement utils/auth_helpers.py:* file accumulates auth concerns; should be auth/ module → deferred (separate refactor task)`

Severity buckets:
- **structure** — placement, layering, ownership
- **naming** — names that hide work
- **duplication** — near-duplicate logic
- **simplicity** — over-built abstractions
- **size** — files growing past comfort

## Decision Output

- **No findings** — Structure matches plan. Approve.
- **Minor findings (naming, small duplication)** — Fix in this task before close-out.
- **Major findings (placement wrong, layer violations)** — Open a follow-up task; do not close current task without addressing or explicitly deferring.

## Cross-References

- Run this **after architect-mode-driven implementation**. They are a pair: architect-mode sets the plan, architecture-review checks the result.
- For correctness/security/tests, use a separate code-review skill — this skill only covers structure.

## Common Mistakes

- **Mixing structural and logic review.** Keep these separate. Run logic review afterwards.
- **Skipping when "it's only one file".** One file growing 300 LOC over budget is exactly when this check matters most.
- **Accepting "it's fine for now".** That's how files reach 4000 LOC. Either justify in `ARCHITECTURE.md` or fix it now.
