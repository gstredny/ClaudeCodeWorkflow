# Tips and Lessons Learned

### From 60+ tasks on a production codebase

**Session discipline saves hours**
- Start: "Check docs/tasks/open first"
- End: "What changed, test results, what's left"

**WHY blocks compound over time**
- Every painful mistake becomes a permanent guardrail
- After a few months, CLAUDE.md prevents entire categories of errors

**Declarative beats imperative every time**
- "Make this test pass" > 10-step implementation plan
- Define the what, let Claude find the how

**First CI run always fails — and that's fine**
- Catches implicit dependencies that work locally
- Treat the first failure as expected, not alarming

**Test before declaring victory**
- Hooks enforce this automatically
- "Works on my machine" is not Done Criteria

**The task file is the source of truth**
- When in doubt, read the task file
- If the task file is wrong, fix the task file

---

**Speaker notes:**
These tips come from real retrospective entries. The system gets better over time because every mistake generates a rule, every rule generates enforcement, and enforcement prevents recurrence. Start small — you don't need everything on day one. The workflow will grow with you.
