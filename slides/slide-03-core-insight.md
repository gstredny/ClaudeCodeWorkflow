# The Core Insight

## Declarative, not imperative

| Old Way (Imperative) | New Way (Declarative) |
|---|---|
| "Fix file.py line 312" | "Make this test pass" |
| "Change the mapping from X to Y" | "All mappings match the schema" |
| "Then update the test" | "Constraint: don't add new queries" |
| "Then run pytest" | "Figure out how to make it work" |

### Tell Claude WHAT the result should be, not HOW to get there

- Define success criteria (testable outcomes)
- Define constraints (what NOT to do)
- Let Claude figure out the implementation
- Claude can loop, try approaches, and self-correct

---

**Speaker notes:**
Imperative instructions break when anything unexpected happens. Declarative instructions let Claude use its strengths — reasoning about code, trying multiple approaches, and self-correcting. You define the destination, Claude finds the route.
