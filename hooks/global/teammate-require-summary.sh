#!/bin/bash
INPUT=$(cat)
TEAMMATE_NAME=$(echo "$INPUT" | jq -r '.teammate_name // "unknown"')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')

if [ -f "$TRANSCRIPT_PATH" ]; then
  RECENT=$(tail -c 4000 "$TRANSCRIPT_PATH")
  HAS_FILES=$(echo "$RECENT" | grep -icE "(files? (changed|modified|updated|created)|changed .+\.(py|jsx|tsx|js|ts|sql|yaml|json))" || true)
  HAS_RESULTS=$(echo "$RECENT" | grep -icE "(test result|tests? pass|tests? fail|pytest|completed|finished|done with)" || true)
  if [ "$HAS_FILES" -gt 0 ] && [ "$HAS_RESULTS" -gt 0 ]; then
    exit 0
  fi
fi

echo "WORKFLOW RULE (Agent Teams): Before going idle, send a completion summary to the lead agent:
1. What was changed (specific files and lines)
2. Test results (what passed/failed)
3. Any issues or concerns discovered
Send this summary via messaging to the lead, then you can idle." >&2
exit 2
