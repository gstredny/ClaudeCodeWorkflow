#!/bin/bash
# PreToolUse hook: Block task moves from open/ to closed/ unless code review is completed or not required.
# Catches both "mv" and "git mv" commands.
# Works alongside require-retro-before-close.sh — both must pass for close-out.

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

# Extract the task file path from the source (docs/tasks/open/SOMETHING.md)
TASK_FILE=$(echo "$COMMAND" | grep -oE 'docs/tasks/open/[^ ]+' | head -1)
if [ -z "$TASK_FILE" ]; then
  exit 0
fi

# Resolve path relative to project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
TASK_PATH="$PROJECT_DIR/$TASK_FILE"

# If the task file doesn't exist, let the mv fail naturally
if [ ! -f "$TASK_PATH" ]; then
  exit 0
fi

# Check for Code Review status in the task file
# Accept: "completed" or "not required" (case-insensitive)
REVIEW_COMPLETED=$(grep -icE '## Code Review:\s*(completed|not required|not-required)' "$TASK_PATH" || true)

if [ "$REVIEW_COMPLETED" -gt 0 ]; then
  exit 0
fi

# Check if there's a Code Review field at all
HAS_REVIEW_FIELD=$(grep -icE '## Code Review:' "$TASK_PATH" || true)

if [ "$HAS_REVIEW_FIELD" -eq 0 ]; then
  echo "WORKFLOW RULE: Task file is missing the '## Code Review:' field. Add '## Code Review: required' (or 'not required' if this task doesn't need review) to the task file before closing." >&2
  exit 2
fi

echo "WORKFLOW RULE: Code review is not complete. The task file shows code review is required but not yet completed. Either:" >&2
echo "  1. Complete the code review and set '## Code Review: completed'" >&2
echo "  2. If this task genuinely doesn't need review, set '## Code Review: not required'" >&2
echo "" >&2
echo "Code review follows the same plan/explore/review/execute loop:" >&2
echo "  - Plan the review with Claude AI (browser) — get a review prompt" >&2
echo "  - Send to Claude Code to explore and plan the review" >&2
echo "  - Refine the review plan with Claude AI" >&2
echo "  - Execute the review with Claude Code — log findings, fix issues" >&2
exit 2
