---
name: architect-mode
description: Use when adding a new file, module, or non-trivial code path; when about to type "utils.py" or "helpers/"; when the change spans more than one file; when restructuring or refactoring; or when a reviewer asks "where does this belong?"
---

# Architect Mode

A pre-implementation thinking pass that catches structural mistakes before they get written. Forces the question "where does this belong?" to be answered with reasons before any code is typed.

## When to Run

Before writing or moving code that:
- Creates a new file or module
- Touches more than one file in service of a single change
- Introduces a new pattern or abstraction
- Lands in a file named `utils`, `helpers`, `manager`, `handler`, or `common`

If the change is a one-line bugfix in an existing well-named function, skip this skill.

## Why this skill exists

Real codebases don't have 500-line rules. Linux has 3000-line files. React's median is ~300. Google's style guide says "prefer small files" with no number. The discipline real engineers internalize is the "and" test, the change-locality test, and the reading-cost test — not a line count.

Claude doesn't have that instinct yet. When you ask it to fix a bug in `executor.py`, the fix needs a new helper. A senior engineer thinks "this helper isn't really executor's job, it's retry logic — new file." Claude thinks "executor.py has a function-shaped hole, I'll fill it." Repeat 40 times = god object.

This skill substitutes mechanical questions for the missing instinct. Run them out loud, in writing, every time. The line count rule is the smoke alarm; these questions are the fire drill.

## The 8 Questions

Answer each one **out loud, in writing, with a reason** — not "yes" / "no". Save the answers in the task file's Context section or in a scratch note.

> NOTE: This list is intentionally duplicated in `CLAUDE.md`'s "Architect Questions to Ask Constantly" section (added by Prompt 1). If you edit one, edit the other.

1. Where does this belong, and why there?
2. What else lives in that file/module? Are they really the same kind of thing? **The "and" test:** describe the file in one sentence with no "and". If you can't, two responsibilities are sharing one room.
3. What changes together with this?
4. If [business rule] changes, how many files have to change? **Sweet spot: 2–4 files for a typical change.** 14 files → boundaries are too granular. 1 file that's 2000 lines → boundaries are too coarse.
5. Is anything else doing something similar? Should they share?
6. What's the simplest version of this? Are we building more than we need?
7. Can you explain this without using the words "utils," "helper," "manager," or "handler"?
8. If a new engineer joined tomorrow, which file would confuse them most? **The 60-second test:** can they load this file's purpose in 60 seconds? If they're scrolling for 10 minutes, split.

## Five Structural Reading Techniques

Use these *while answering the questions* to ground your reasoning in the actual codebase, not in assumptions.

1. **Ask for a map, not the territory.** Get a one-screen list of directories with a one-line purpose for each. If you can't write that list yourself, you don't know the system well enough to add to it.
2. **Narrate flows.** Pick a real user action ("user clicks save"). Trace it as a one-paragraph story across modules. Gaps in the story are gaps in your model.
3. **Plain-English rule.** State the business rule the code enforces in one English sentence. If you need three sentences, you're describing an implementation, not a rule.
4. **Names as X-ray.** Read every name in the diff (file, class, function, variable). Names that hide their purpose ("Manager", "Util", "Handler", "doStuff") flag confused responsibility before any logic is read.
5. **Track size weekly.** Note line counts on landmark modules. A file growing 3x in two weeks is shouting that it's accumulating unrelated responsibilities.

## Decision Output

Produce one of three answers, with reasons:

- **PROCEED — pattern is clear.** All 8 questions answered cleanly; structure matches existing patterns; new code lives where similar code already lives.
- **REFINE — structure unclear.** One or more questions returned a vague answer (e.g., "it goes in utils because that's where misc stuff goes"). Move the file or rename before implementing.
- **STOP — wrong layer.** The change is being placed in a layer that doesn't own this concern. Re-plan placement before any code is written.

## Cross-References

- After implementation, run the **architecture-review** skill against the changes.
- **plan-review** is also a pre-execution gate but checks scope/criteria. Both can run in sequence: architect-mode first (structure), plan-review second (scope).

## Anti-Patterns

- **Don't** answer the 8 questions in your head. Write them down. Unwritten answers are usually wrong.
- **Don't** skip questions 7 or 8 — they catch the most damage.
- **Don't** treat this as a rubber-stamp. If every change passes, you're not asking hard enough.
