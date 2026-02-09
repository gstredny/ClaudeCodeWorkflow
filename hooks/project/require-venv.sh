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

if echo "$COMMAND" | grep -qE '(^|\s|&&|\|\||;)(python3?|pip3?|pytest|uvicorn|fastapi|alembic)\s'; then
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
