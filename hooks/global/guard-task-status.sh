#!/bin/bash
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
FILE_PATH=""

if [ "$TOOL_NAME" = "Write" ]; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')
elif [ "$TOOL_NAME" = "Edit" ]; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty')
fi

if echo "$FILE_PATH" | grep -q 'docs/tasks/'; then
  if echo "$CONTENT" | grep -iqE '## Status:\s*(done|complete|completed|closed)'; then
    jq -n '{
      "decision": "block",
      "reason": "WORKFLOW RULE: You cannot set Status to done/complete/closed. Only the user can close tasks. Set Status to \"needs verification\" instead, then walk through Done Criteria with the user."
    }'
    exit 0
  fi
  if [ "$TOOL_NAME" = "Write" ]; then
    if echo "$FILE_PATH" | grep -q 'docs/tasks/open/'; then
      ATTEMPT_COUNT=$(echo "$CONTENT" | grep -c '^\- \[' || true)
      if [ -f "$FILE_PATH" ]; then
        EXISTING_ATTEMPTS=$(grep -c '^\- \[' "$FILE_PATH" 2>/dev/null || true)
        if [ "$EXISTING_ATTEMPTS" -gt 0 ] && [ "$ATTEMPT_COUNT" -lt "$EXISTING_ATTEMPTS" ]; then
          jq -n '{
            "decision": "block",
            "reason": "WORKFLOW RULE: Attempts log is append-only. You are overwriting existing attempts. Use Edit to append new entries instead."
          }'
          exit 0
        fi
      fi
    fi
  fi
fi
exit 0
