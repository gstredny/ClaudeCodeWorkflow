#!/bin/bash
# PreToolUse hook: Combined close-out preflight check.
# Blocks task moves from open/ to closed/ unless ALL conditions are met:
#   1. All Done/Success Criteria checkboxes are checked
#   2. RETRO.md has a matching entry
#   3. Code Review field is "completed" or "not required"
# Reports ALL failures in a single message so Claude can fix them in one pass.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# Only care about mv commands moving from open/ to closed/
if ! echo "$COMMAND" | grep -qE '(^|\s|&&|\|\||;)(git\s+mv|mv)\s' ; then
  exit 0
fi
if ! echo "$COMMAND" | grep -q 'docs/tasks/open/' ; then
  exit 0
fi
if ! echo "$COMMAND" | grep -q 'docs/tasks/closed/' ; then
  exit 0
fi

TASK_FILE=$(echo "$COMMAND" | grep -oE 'docs/tasks/open/[^ ]+' | head -1)
if [ -z "$TASK_FILE" ]; then
  exit 0
fi

TASK_STEM=$(basename "$TASK_FILE" .md)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FULL_PATH="$PROJECT_DIR/$TASK_FILE"

if [ ! -f "$FULL_PATH" ]; then
  exit 0
fi

FAILURES=""
PASSES=""

# --- Check 1: Done Criteria ---
UNCHECKED=$(grep -n '^\s*- \[ \]' "$FULL_PATH" 2>/dev/null)
if [ -n "$UNCHECKED" ]; then
  COUNT=$(echo "$UNCHECKED" | wc -l | tr -d ' ')
  FAILURES="${FAILURES}  ✗ $COUNT Done Criteria checkbox(es) still unchecked\n"
else
  PASSES="${PASSES}  ✓ All Done Criteria checked\n"
fi

# --- Check 2: Retro entry ---
RETRO_PATH="$PROJECT_DIR/docs/tasks/RETRO.md"
if [ ! -f "$RETRO_PATH" ]; then
  FAILURES="${FAILURES}  ✗ docs/tasks/RETRO.md does not exist — create it with a retro entry for '$TASK_STEM'\n"
elif ! grep -qi "$TASK_STEM" "$RETRO_PATH" ; then
  FAILURES="${FAILURES}  ✗ No retro entry for '$TASK_STEM' in docs/tasks/RETRO.md\n"
else
  PASSES="${PASSES}  ✓ Retro entry found\n"
fi

# --- Check 3: Code Review ---
REVIEW_COMPLETED=$(grep -icE '## Code Review:\s*(completed|not required|not-required)' "$FULL_PATH" || true)
if [ "$REVIEW_COMPLETED" -gt 0 ]; then
  PASSES="${PASSES}  ✓ Code Review resolved\n"
else
  HAS_REVIEW_FIELD=$(grep -icE '## Code Review:' "$FULL_PATH" || true)
  if [ "$HAS_REVIEW_FIELD" -eq 0 ]; then
    FAILURES="${FAILURES}  ✗ Task file missing '## Code Review:' field\n"
  else
    FAILURES="${FAILURES}  ✗ Code Review not completed (set to 'completed' or 'not required')\n"
  fi
fi

# --- Report ---
if [ -n "$FAILURES" ]; then
  FAIL_COUNT=$(echo -e "$FAILURES" | grep -c '✗' || true)
  {
    echo "CLOSE-OUT PREFLIGHT — $FAIL_COUNT issue(s) to resolve before moving to closed/:"
    echo -e "$FAILURES$PASSES"
    if echo -e "$FAILURES" | grep -q 'Done Criteria'; then
      echo "Unchecked criteria:"
      echo "$UNCHECKED" | while IFS= read -r line; do
        CRITERION=$(echo "$line" | sed 's/^[0-9]*://')
        echo "  $CRITERION"
      done
      echo ""
    fi
    echo "Resolve all issues above, then retry the move."
  } >&2
  exit 2
fi

exit 0
