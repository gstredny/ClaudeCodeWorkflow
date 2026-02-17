# RETRO.md = Learning Across Tasks

### Append-only log of lessons learned

```
### 2026-02-06 Task: fix-session-timeout
- What worked: httpOnly cookies for token persistence
- What broke: localStorage approach (tokens cleared on refresh)
- Workflow friction: None
- Pattern: When persisting auth tokens, prefer server-side
  storage (cookies) over client-side (localStorage) for
  security and cross-tab consistency.
```

### How it compounds:

1. **Session hook** injects last 10 entries at session start
2. Claude starts every session knowing recent lessons
3. Same mistakes stop repeating across tasks
4. Patterns become institutional knowledge

### The "Pattern" field is most valuable

- Good: "Check both absolute and relative imports when verifying unused modules"
- Bad: "Fixed the import bug in auth.py"

---

**Speaker notes:**
The retro log is what makes this system improve over time. Without it, lesson learned in Task 5 are forgotten by Task 20. The session-start hook automatically injects recent entries, so Claude learns from past mistakes without you having to remind it. The close-out-preflight hook enforces that every task produces a retro entry (along with checking done criteria and code review).
