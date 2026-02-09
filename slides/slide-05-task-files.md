# Task Files = Persistent Memory

### Every task gets a file in `docs/tasks/open/`

```
## Task: Fix user session timeout
## Status: in progress
## Goal: Sessions persist across page refreshes

## Done Criteria:
- [ ] Session survives browser refresh
- [ ] Token refresh happens silently
- [ ] pytest test_session.py passes

## Left Off At:
Modified auth.py line 312. test_login passes
but test_session fails on line 45 — token response
missing refresh_token field.

## Attempts:
- 2026-02-05: Added localStorage persistence
  -> tokens cleared on refresh -> failed
- 2026-02-06: Switched to httpOnly cookies
  -> tokens persist, but refresh endpoint 401s -> partial
```

---

**Speaker notes:**
This is the heart of the system. Claude reads this file at the start of every session and knows exactly where things stand. The Attempts log prevents retrying failed approaches. "Left Off At" enables cold resumption — a new session can pick up without asking any questions.
