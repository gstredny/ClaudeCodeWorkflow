#!/bin/bash
# filesize-guard - block writes that push files past MAX_FILE_LINES (default 500).
# Files listed in .claude/filesize-baseline.txt are grandfathered under
# shrink-or-equal: edits to them are blocked if they would grow the file.
# Triggers on PreToolUse for Write, Edit, MultiEdit. Read passes through.

set -u

MAX_FILE_LINES="${MAX_FILE_LINES:-500}"
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
BASELINE_FILE="${BASELINE_FILE:-$PROJECT_ROOT/.claude/filesize-baseline.txt}"

block() {
  echo "filesize-guard: $1" 1>&2
  exit 2
}

count_text_lines() {
  printf '%s' "$1" | awk 'END { print NR + 0 }'
}

count_file_lines() {
  [ -f "$1" ] || { printf '0\n'; return; }
  awk 'END { print NR + 0 }' "$1"
}

is_grandfathered() {
  [ -f "$BASELINE_FILE" ] || return 1
  grep -v '^[[:space:]]*#' "$BASELINE_FILE" | grep -v '^[[:space:]]*$' | grep -Fxq "$1"
}

INPUT=$(cat)
[ -n "$INPUT" ] || exit 0

command -v jq > /dev/null || block "jq required but not found"

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')
case "$TOOL_NAME" in
  Write|Edit|MultiEdit) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -n "$FILE_PATH" ] || block "missing tool_input.file_path"

RELATIVE_PATH="${FILE_PATH#$PROJECT_ROOT/}"

CURRENT_LINES=$(count_file_lines "$FILE_PATH")

case "$TOOL_NAME" in
  Write)
    NEW_CONTENT=$(printf '%s' "$INPUT" | jq -r '.tool_input.content // empty')
    PROJECTED_LINES=$(count_text_lines "$NEW_CONTENT")
    ;;
  Edit)
    OLD_STRING=$(printf '%s' "$INPUT" | jq -r '.tool_input.old_string // empty')
    NEW_STRING=$(printf '%s' "$INPUT" | jq -r '.tool_input.new_string // empty')
    OLD_LINES=$(count_text_lines "$OLD_STRING")
    NEW_LINES=$(count_text_lines "$NEW_STRING")
    PROJECTED_LINES=$((CURRENT_LINES + NEW_LINES - OLD_LINES))
    ;;
  MultiEdit)
    DELTA=$(printf '%s' "$INPUT" | jq -r '
      def lc: if . == "" then 0 else split("\n") | length - (if endswith("\n") then 1 else 0 end) end;
      [.tool_input.edits[] | (.new_string | lc) - (.old_string | lc)] | add // 0
    ')
    PROJECTED_LINES=$((CURRENT_LINES + DELTA))
    ;;
esac

[ "$PROJECTED_LINES" -lt 0 ] && PROJECTED_LINES=0

if is_grandfathered "$RELATIVE_PATH"; then
  if [ "$PROJECTED_LINES" -le "$CURRENT_LINES" ]; then
    exit 0
  fi
  block "$RELATIVE_PATH grandfathered at $CURRENT_LINES LOC; projected $PROJECTED_LINES exceeds - extract first (no-growth rule)"
fi

if [ "$PROJECTED_LINES" -gt "$MAX_FILE_LINES" ]; then
  block "$RELATIVE_PATH would exceed MAX_FILE_LINES=$MAX_FILE_LINES (projected $PROJECTED_LINES) - extract first"
fi

exit 0
