# Task File Rules

### Four non-negotiable rules

**1. Status is never "done"**
- Claude sets "needs verification"
- Only YOU can close a task
- After verifying every Done Criterion

**2. Attempts log is append-only**
- Log immediately after each attempt (not batched)
- Never delete or overwrite entries
- 3 attempts in one session = 3 dated entries

**3. "Left Off At" must enable cold resume**
- Bad: "Working on the bug"
- Good: "Modified auth.py:312, test_login passes but test_session fails — need to check refresh_token field"

**4. Only the user closes tasks**
- Claude proposes completion
- You walk through Done Criteria
- You say "close it out"

---

**Speaker notes:**
These rules are enforced by automated hooks (covered in a later slide). The append-only attempts log is critical — it's what prevents Claude from going in circles. Status never being "done" ensures you always verify before declaring victory.
