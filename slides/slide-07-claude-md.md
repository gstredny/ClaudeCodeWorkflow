# CLAUDE.md = Project Rules

### A contract between you and Claude Code

Claude reads `CLAUDE.md` at the start of every session.

### Three sections:

**Task Management** (universal — same for every project)
- Check for existing tasks before working
- Create task files, log attempts, never say "done"

**Critical Rules with WHY blocks** (project-specific)
```
### .env IS SACRED
> WHY: Claude modified .env before — lost credentials.
> Recovery took two days.

- READ-ONLY. Never modify without approval.
- Missing var? Say so. NEVER create new .env
```

**Constraints** (project-specific)
- No new endpoints
- No UI changes without approval
- Preserve caching decorators

### The secret: WHY blocks
Claude follows rules better when it understands *consequences*.

---

**Speaker notes:**
WHY blocks are the single most impactful pattern. "Don't modify .env" is a rule Claude might break. "Don't modify .env because we lost all credentials and it took two days to recover" is a rule Claude will never break. Every painful mistake becomes a permanent guardrail. Your CLAUDE.md grows over time and gets smarter.
