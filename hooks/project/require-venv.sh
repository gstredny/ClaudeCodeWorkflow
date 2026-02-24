#!/bin/bash
# ============================================================================
# LANGUAGE: Python
# PURPOSE: Blocks Python/pip/pytest commands unless venv is activated.
#
# CUSTOMIZE for other languages:
#   - Node.js: Check for node_modules/.bin in PATH or npx usage
#   - Go: Check GOPATH or go.mod presence (usually not needed)
#   - Rust: Check cargo availability (usually not needed)
#   - Ruby: Check for bundle exec prefix
#
# To disable: Remove the PreToolUse hook registration from .claude/settings.json
# ============================================================================

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# Split command into segments on &&, ||, ;, | and check if any segment's
# first word (the actual command) is a Python keyword. This avoids false
# positives when Python keywords appear as arguments (e.g., grep python file.py).
PYTHON_CMDS='python|python3|pip|pip3|pytest|uvicorn|fastapi|alembic'
FOUND_PYTHON_CMD=false

# Split on &&, ||, ;, | delimiters and check first word of each segment
while IFS= read -r segment; do
  # Trim leading whitespace and extract the first word (the command name)
  first_word=$(echo "$segment" | sed 's/^[[:space:]]*//' | awk '{print $1}')
  if echo "$first_word" | grep -qE "^(${PYTHON_CMDS})$"; then
    FOUND_PYTHON_CMD=true
    break
  fi
done <<< "$(echo "$COMMAND" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g; s/|/\n/g')"

if $FOUND_PYTHON_CMD; then
  if echo "$COMMAND" | grep -qE 'source\s+\.venv/bin/activate'; then
    exit 0
  fi
  if echo "$COMMAND" | grep -qE '\.venv/bin/(python|pip|pytest|uvicorn)'; then
    exit 0
  fi
  if echo "$COMMAND" | grep -qE '(python|pip).*--version|which (python|pip)'; then
    exit 0
  fi
  echo "WORKFLOW RULE: Always activate venv before Python commands. Prefix with: source .venv/bin/activate && " >&2
  exit 2
fi
exit 0
