#!/bin/bash
# PreToolUse hook: Block task moves from open/ to closed/ unless all Done/Success Criteria are checked.
# Must run BEFORE require-retro-before-close.sh.

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

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FULL_PATH="$PROJECT_DIR/$TASK_FILE"

if [ ! -f "$FULL_PATH" ]; then
  exit 0
fi

UNCHECKED=$(grep -n '^\s*- \[ \]' "$FULL_PATH" 2>/dev/null)

if [ -n "$UNCHECKED" ]; then
  COUNT=$(echo "$UNCHECKED" | wc -l | tr -d ' ')
  echo "WORKFLOW RULE: Cannot close task — $COUNT Done Criteria checkbox(es) still unchecked." >&2
  echo "" >&2
  echo "Unchecked criteria:" >&2
  echo "$UNCHECKED" | while IFS= read -r line; do
    CRITERION=$(echo "$line" | sed 's/^[0-9]*://')
    echo "  $CRITERION" >&2
  done
  echo "" >&2
  echo "Walk through each criterion with the user and mark [x] before closing." >&2
  exit 2
fi

exit 0
