#!/bin/bash
cat << 'EOF'
WORKFLOW RULES (auto-injected by session hook):
1. Check docs/tasks/open/ FIRST — read any existing task files before doing anything
2. Task files are your persistent memory. If a task exists, resume from "Left Off At"
3. Never retry approaches already logged in the Attempts section
4. Always activate venv (if .venv/ exists): source .venv/bin/activate before any Python command
5. Never set Status to "done" — only "needs verification"
6. Attempts log is append-only. Log every attempt immediately after trying it
7. If this is an agent-team task (Execution Mode: agent-team), use delegate mode — you own the task file exclusively, teammates report via messaging
8. End every session with: what changed, test results, what's left
EOF

# Inject recent retro entries if RETRO.md exists in the current project
RETRO_FILE="docs/tasks/RETRO.md"
if [ -f "$RETRO_FILE" ]; then
  if grep -q "^### " "$RETRO_FILE" 2>/dev/null; then
    echo ""
    echo "RECENT RETRO ENTRIES (from docs/tasks/RETRO.md):"
    # Get the line number where the 10th-from-last entry starts
    START_LINE=$(grep -n "^### " "$RETRO_FILE" | tail -10 | head -1 | cut -d: -f1)
    tail -n +"$START_LINE" "$RETRO_FILE"
  fi
fi

exit 0
