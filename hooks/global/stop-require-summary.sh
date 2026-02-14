#!/bin/bash
INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')

if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

if [ -f "$TRANSCRIPT_PATH" ]; then
  RECENT=$(tail -c 5000 "$TRANSCRIPT_PATH")

  # Check 1: File-level detail in what changed — must mention actual file paths (extensions)
  HAS_FILE_DETAIL=$(echo "$RECENT" | grep -icE '\.(py|js|ts|jsx|tsx|go|rs|md|sh|json|yaml|yml|toml|css|html|vue|rb|java|kt|swift|c|cpp|h|hpp|sql|tf|hcl)\b' || true)

  # Check 2: Specific test results — must include numbers near test keywords
  HAS_TEST_COUNTS=$(echo "$RECENT" | grep -icE '([0-9]+ (pass|fail|test|error|skip|succeed)|[0-9]+/[0-9]+|passed.*failed|tests?:?\s*[0-9])' || true)

  # Check 3: What's left / next steps
  HAS_LEFT=$(echo "$RECENT" | grep -icE "(what's left|remaining|next steps|left to do|todo|still need|left off|nothing.*(left|remain))" || true)

  if [ "$HAS_FILE_DETAIL" -gt 0 ] && [ "$HAS_TEST_COUNTS" -gt 0 ] && [ "$HAS_LEFT" -gt 0 ]; then
    exit 0
  fi

  # Build specific feedback about what's missing
  MISSING=""
  if [ "$HAS_FILE_DETAIL" -eq 0 ]; then
    MISSING="${MISSING}\n- MISSING: File-level detail. List EVERY file modified with what changed in each."
  fi
  if [ "$HAS_TEST_COUNTS" -eq 0 ]; then
    MISSING="${MISSING}\n- MISSING: Specific test results with counts (e.g., '12 passed, 0 failed')."
  fi
  if [ "$HAS_LEFT" -eq 0 ]; then
    MISSING="${MISSING}\n- MISSING: What's left to do / next steps."
  fi
fi

jq -n --arg missing "$MISSING" '{
  "decision": "block",
  "reason": ("WORKFLOW RULE: Your summary is not detailed enough." + $missing + "\n\nProvide a detailed summary with ALL three sections:\n\n1. What changed — list EVERY file modified with what was changed in each:\n   Example: \"Modified src/auth/service.py — replaced JWT validation with token\n   introspection. Updated tests/test_auth.py — added mock for introspection endpoint.\"\n\n2. Test results — specific counts, not just \"tests pass\":\n   Example: \"pytest tests/test_auth.py: 12/12 passed. Full suite: 156 passed, 0 failed.\"\n\n3. What'\''s left — specific next steps:\n   Example: \"Still need to update API docs for the new token flow. Integration test\n   with staging auth server not yet run.\"\n\nProvide this detailed summary now, then you can stop.")
}'
