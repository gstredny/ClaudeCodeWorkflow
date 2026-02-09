#!/bin/bash
# ============================================================================
# PURPOSE: Runs tests before allowing task completion. If tests fail, the
#          task cannot be marked as completed.
#
# CUSTOMIZE the test command below for your project:
#   - Python:  pytest --tb=short -q
#   - Node.js: npm test -- --watchAll=false
#   - Go:      go test ./...
#   - Rust:    cargo test
#   - Java:    mvn test -q
#
# To disable: Remove the TaskCompleted hook registration from .claude/settings.json
# ============================================================================

INPUT=$(cat)
TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task_subject // "unknown task"')
CWD=$(echo "$INPUT" | jq -r '.cwd')

cd "$CWD" 2>/dev/null || exit 0

# CUSTOMIZE: Activate your language's environment if needed
if [ -d ".venv" ]; then
  source .venv/bin/activate 2>/dev/null
fi

# CUSTOMIZE: Change this to your test runner
if ! command -v pytest &>/dev/null; then
  exit 0
fi

# CUSTOMIZE: Change the find pattern for your test file naming convention
TEST_FILES=$(find . -name "test_*.py" -o -name "*_test.py" 2>/dev/null | head -5)
if [ -z "$TEST_FILES" ]; then
  exit 0
fi

# CUSTOMIZE: Change this to your test command
TEST_OUTPUT=$(pytest --tb=short -q 2>&1)
TEST_EXIT=$?

if [ $TEST_EXIT -ne 0 ]; then
  echo "WORKFLOW RULE: Tests must pass before a task can be completed. Task: '$TASK_SUBJECT'

pytest output:
$TEST_OUTPUT

Fix failing tests before marking this task as completed." >&2
  exit 2
fi
exit 0
