#!/bin/bash
# PreToolUse hook: Block task moves from open/ to closed/ unless RETRO.md has a matching entry.
# Catches both "mv" and "git mv" commands.

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

# Extract the task filename from the source path (docs/tasks/open/SOMETHING.md)
TASK_FILE=$(echo "$COMMAND" | grep -oE 'docs/tasks/open/[^ ]+' | head -1)
if [ -z "$TASK_FILE" ]; then
  exit 0
fi

# Get the filename stem (without path and .md extension)
TASK_STEM=$(basename "$TASK_FILE" .md)

# Resolve RETRO.md relative to the project directory (CWD may differ)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
RETRO_PATH="$PROJECT_DIR/docs/tasks/RETRO.md"

# Check if RETRO.md exists
if [ ! -f "$RETRO_PATH" ]; then
  echo "WORKFLOW RULE: docs/tasks/RETRO.md does not exist. Create it first with a retro entry for task '$TASK_STEM' before moving the task to closed/." >&2
  exit 2
fi

# Check for matching entry (case-insensitive)
if ! grep -qi "$TASK_STEM" "$RETRO_PATH" ; then
  echo "WORKFLOW RULE: No retro entry found for '$TASK_STEM' in docs/tasks/RETRO.md. Append a retro entry (### [date] Task: $TASK_STEM) before moving the task to closed/." >&2
  exit 2
fi

exit 0
