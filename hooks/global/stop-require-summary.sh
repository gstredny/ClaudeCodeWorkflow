#!/bin/bash
INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')

if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

if [ -f "$TRANSCRIPT_PATH" ]; then
  RECENT=$(tail -c 3000 "$TRANSCRIPT_PATH")
  HAS_CHANGES=$(echo "$RECENT" | grep -icE "(what changed|changes made|modified|updated|created|deleted|summary)" || true)
  HAS_TESTS=$(echo "$RECENT" | grep -icE "(test result|tests? pass|tests? fail|pytest|all tests|no tests|npm test)" || true)
  HAS_LEFT=$(echo "$RECENT" | grep -icE "(what's left|remaining|next steps|left to do|todo|still need|left off)" || true)
  if [ "$HAS_CHANGES" -gt 0 ] && [ "$HAS_TESTS" -gt 0 ] && [ "$HAS_LEFT" -gt 0 ]; then
    exit 0
  fi
fi

jq -n '{
  "decision": "block",
  "reason": "WORKFLOW RULE: You must end every session with a summary before stopping. Provide:\n1. What changed (specific files and modifications)\n2. Test results (what passed/failed, or state if no tests were run)\n3. What is left to do\n\nProvide this summary now, then you can stop."
}'
