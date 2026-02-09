---
name: task-manager
description: Session-persistent task management using docs/tasks/ files for continuity across Claude Code sessions
---

# Task Manager Skill

Manage development tasks with persistence across Claude Code sessions using markdown files in `docs/tasks/`.

## Session Workflow

### At Session Start
1. Check `docs/tasks/` for existing task files
2. If user's request matches an existing task → read it, resume from "Left Off At"
3. If no match → create new task file before starting work

### During Work
- Update task file when significant progress is made
- Log failed approaches in "Attempts" section (prevents retry loops)
- Keep "Left Off At" current

### At Session End
- **ALWAYS** update task file with:
  - What was accomplished
  - Exact stopping point
  - What's next

### On Task Completion
- Move file to `docs/tasks/completed/`

## Task File Location

- Active tasks: `docs/tasks/[descriptive-name].md`
- Completed tasks: `docs/tasks/completed/[descriptive-name].md`

## Template

See `templates/task-file.md` for the full template.

## Rules

1. **One task per file** - don't combine unrelated work
2. **Descriptive names** - use kebab-case (e.g., `chart-legend-fix.md`)
3. **Never skip the Attempts log** - failed approaches are valuable context
4. **Be specific in "Left Off At"** - a new session should resume without asking questions
5. **Done criteria must be testable** - not vague like "works correctly"
