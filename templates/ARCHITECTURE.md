# Architecture

> One file. One screen if possible. Keep it short and updated, or it lies.

This document is the structural map of [PROJECT NAME]. It exists so a new engineer (or a returning Claude Code session) can answer "where does X belong?" without reading every file.

## Top-Level Map

| Module | Responsibility (one sentence) | Does NOT own | Depends on |
|--------|-------------------------------|--------------|------------|
| `[CUSTOMIZE: src/api/]` | HTTP entry points and request validation | Business rules, persistence | `domain/`, `models/` |
| `[CUSTOMIZE: src/domain/]` | Business rules and invariants | I/O, framework concerns | `models/` |
| `[CUSTOMIZE: src/infra/]` | Database, external services, file I/O | Business rules | `models/` |
| `[CUSTOMIZE: tests/]` | Unit + integration tests | Production code | all |

(Replace with your actual layout. If you have more than 8 rows, your map is too wide.)

## Dependency Direction Rule

State the import direction in one paragraph. Example:

> `api/` may import from `domain/` and `models/`. `domain/` may import from `models/` only. `infra/` may import from `models/` only. `models/` imports from nothing in this project. Any other direction is a structural bug, not a style choice.

A circular dependency is an architecture bug, not a code-style issue.

## How to Add a New Feature — 3-Step Decision Tree

1. **Does an existing module already own this responsibility?**
   - **Yes** → add to it (and check its size budget).
   - **No** → continue.

2. **Is this a new responsibility that fits the dependency direction?**
   - **Yes** → create a new module at the correct layer. Add a row to the map above.
   - **No** → reconsider whether the dependency rule needs an exception, and document the exception in this file.

3. **What does this module NOT own?**
   - Write that down before writing code. Resist scope creep by listing what the new module rejects.

## Size Budgets

All files: hard cap 500 LOC (enforced by `filesize-guard` hook).
Comfortable upper bound: 300 LOC.

Files exceeding the hard cap must:
1. Be listed in `.claude/filesize-baseline.txt` (grandfathered)
2. Be documented here with a justification
3. Have a stated path back under 500 LOC

| File | Current LOC | Why it exceeds | Path back |
|------|-------------|----------------|-----------|
| (example) `src/orchestrator/pipeline.py` | 820 | Coordinates 6 stages with shared state | Extract stage runners to `src/orchestrator/stages/` |

## Conventions

- **No `utils.py`, `helpers.py`, `manager.py`, `handler.py`, or `common.py`** without explicit justification. Files named for what they own, not for being a junk drawer.
- **One concept per file** when practical. Two unrelated concepts in one file is a structural smell.
- **Tests mirror source layout.** `src/foo/bar.py` → `tests/foo/test_bar.py`.

## When to Update This File

- A new top-level directory is added or removed.
- A business rule changes.
- A module crosses its comfortable upper bound.

If this file is more than 3 months stale, it lies. Either update it or delete it — a wrong map is worse than no map.
