#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Claude Code Workflow Starter Kit${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "This script sets up the task-driven workflow with"
echo "persistent memory, automated hooks, and retrospectives."
echo ""

# Helper function
ask_yn() {
  local prompt="$1"
  local default="${2:-y}"
  if [ "$default" = "y" ]; then
    prompt="$prompt [Y/n]: "
  else
    prompt="$prompt [y/N]: "
  fi
  read -r -p "$prompt" response
  response="${response:-$default}"
  [[ "$response" =~ ^[Yy] ]]
}

# ==========================================
# Step 1: Global hooks
# ==========================================
echo -e "${GREEN}Step 1: Global Hooks${NC}"
echo "These hooks enforce workflow rules across ALL your projects."
echo "Location: ~/.claude/hooks/"
echo ""

if ask_yn "Install global hooks?"; then
  mkdir -p ~/.claude/hooks

  HOOKS=(
    "session-start.sh"
    "stop-require-summary.sh"
    "guard-task-status.sh"
    "require-retro-before-close.sh"
    "require-review-before-close.sh"
    "teammate-require-summary.sh"
  )

  for hook in "${HOOKS[@]}"; do
    if [ -f "$HOME/.claude/hooks/$hook" ]; then
      if diff -q "$SCRIPT_DIR/hooks/global/$hook" "$HOME/.claude/hooks/$hook" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} $hook (already up to date)"
      else
        echo ""
        echo -e "  ${YELLOW}!${NC} $hook already exists and differs:"
        diff "$HOME/.claude/hooks/$hook" "$SCRIPT_DIR/hooks/global/$hook" || true
        echo ""
        if ask_yn "  Overwrite $hook?" "n"; then
          cp "$SCRIPT_DIR/hooks/global/$hook" "$HOME/.claude/hooks/$hook"
          echo -e "  ${GREEN}✓${NC} $hook (updated)"
        else
          echo -e "  ${YELLOW}-${NC} $hook (skipped)"
        fi
      fi
    else
      cp "$SCRIPT_DIR/hooks/global/$hook" "$HOME/.claude/hooks/$hook"
      echo -e "  ${GREEN}✓${NC} $hook (installed)"
    fi
  done

  # Make all hooks executable
  chmod +x ~/.claude/hooks/*.sh
  echo ""
else
  echo -e "  ${YELLOW}-${NC} Skipped global hooks"
  echo ""
fi

# ==========================================
# Step 2: Global settings.json
# ==========================================
echo -e "${GREEN}Step 2: Global Settings${NC}"
echo "Registers hooks in ~/.claude/settings.json"
echo ""

if ask_yn "Install global settings?"; then
  if [ -f "$HOME/.claude/settings.json" ]; then
    echo -e "  ${YELLOW}!${NC} ~/.claude/settings.json already exists."
    echo "  Your current file will not be overwritten."
    echo "  Template saved to: ~/.claude/settings.json.starter-kit-template"
    cp "$SCRIPT_DIR/settings/global-settings.json" "$HOME/.claude/settings.json.starter-kit-template"
    echo ""
    echo "  Merge manually by comparing the two files:"
    echo "    diff ~/.claude/settings.json ~/.claude/settings.json.starter-kit-template"
    echo ""
  else
    cp "$SCRIPT_DIR/settings/global-settings.json" "$HOME/.claude/settings.json"
    echo -e "  ${GREEN}✓${NC} ~/.claude/settings.json (installed)"
  fi
  echo ""
else
  echo -e "  ${YELLOW}-${NC} Skipped global settings"
  echo ""
fi

# ==========================================
# Step 3: Project setup (optional)
# ==========================================
echo -e "${GREEN}Step 3: Project Setup (Optional)${NC}"
echo "Set up the workflow in a specific project directory."
echo ""

if ask_yn "Set up a project now?"; then
  read -r -p "Project directory (absolute path or .): " PROJECT_DIR
  PROJECT_DIR="${PROJECT_DIR:-.}"
  PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || {
    echo -e "${RED}Error: Directory does not exist: $PROJECT_DIR${NC}"
    exit 1
  }

  echo ""
  echo "Setting up in: $PROJECT_DIR"
  echo ""

  # Create task directories
  mkdir -p "$PROJECT_DIR/docs/tasks/open"
  mkdir -p "$PROJECT_DIR/docs/tasks/closed"
  echo -e "  ${GREEN}✓${NC} docs/tasks/open/ (created)"
  echo -e "  ${GREEN}✓${NC} docs/tasks/closed/ (created)"

  # Copy RETRO.md
  if [ ! -f "$PROJECT_DIR/docs/tasks/RETRO.md" ]; then
    cp "$SCRIPT_DIR/templates/RETRO.md" "$PROJECT_DIR/docs/tasks/RETRO.md"
    echo -e "  ${GREEN}✓${NC} docs/tasks/RETRO.md (created)"
  else
    echo -e "  ${GREEN}✓${NC} docs/tasks/RETRO.md (already exists)"
  fi

  # Copy WORKFLOW.md
  if [ ! -f "$PROJECT_DIR/docs/WORKFLOW.md" ]; then
    cp "$SCRIPT_DIR/templates/WORKFLOW.md" "$PROJECT_DIR/docs/WORKFLOW.md"
    echo -e "  ${GREEN}✓${NC} docs/WORKFLOW.md (created)"
  else
    echo -e "  ${GREEN}✓${NC} docs/WORKFLOW.md (already exists)"
  fi

  # Copy CLAUDE.md
  if [ ! -f "$PROJECT_DIR/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/templates/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
    echo -e "  ${GREEN}✓${NC} CLAUDE.md (created — customize the [CUSTOMIZE] sections)"
  else
    echo -e "  ${YELLOW}!${NC} CLAUDE.md already exists (not overwritten)"
    echo "    Template available at: $SCRIPT_DIR/templates/CLAUDE.md"
  fi

  # Copy project hooks
  mkdir -p "$PROJECT_DIR/.claude/hooks"

  for hook in require-venv.sh task-require-tests.sh; do
    if [ ! -f "$PROJECT_DIR/.claude/hooks/$hook" ]; then
      cp "$SCRIPT_DIR/hooks/project/$hook" "$PROJECT_DIR/.claude/hooks/$hook"
      chmod +x "$PROJECT_DIR/.claude/hooks/$hook"
      echo -e "  ${GREEN}✓${NC} .claude/hooks/$hook (installed — see CUSTOMIZE comments)"
    else
      echo -e "  ${GREEN}✓${NC} .claude/hooks/$hook (already exists)"
    fi
  done

  # Copy skills
  for skill_dir in "$SCRIPT_DIR"/.claude/skills/*/; do
    skill_name="$(basename "$skill_dir")"
    mkdir -p "$PROJECT_DIR/.claude/skills/$skill_name"
    if [ ! -f "$PROJECT_DIR/.claude/skills/$skill_name/SKILL.md" ]; then
      cp "$skill_dir/SKILL.md" "$PROJECT_DIR/.claude/skills/$skill_name/SKILL.md"
      echo -e "  ${GREEN}✓${NC} .claude/skills/$skill_name/SKILL.md (installed)"
    else
      echo -e "  ${GREEN}✓${NC} .claude/skills/$skill_name/SKILL.md (already exists)"
    fi
  done

  # Copy project settings
  if [ ! -f "$PROJECT_DIR/.claude/settings.json" ]; then
    cp "$SCRIPT_DIR/settings/project-settings.json" "$PROJECT_DIR/.claude/settings.json"
    echo -e "  ${GREEN}✓${NC} .claude/settings.json (installed)"
  else
    echo -e "  ${YELLOW}!${NC} .claude/settings.json already exists (not overwritten)"
    echo "    Template available at: $SCRIPT_DIR/settings/project-settings.json"
  fi

  echo ""
else
  echo -e "  ${YELLOW}-${NC} Skipped project setup"
  echo "  Run this script again or manually copy files when ready."
  echo ""
fi

# ==========================================
# Summary
# ==========================================
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Setup Complete${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "What was installed:"
echo "  Global hooks:    ~/.claude/hooks/"
echo "  Global settings: ~/.claude/settings.json"
if [ -n "$PROJECT_DIR" ] && [ "$PROJECT_DIR" != "." ]; then
  echo "  Project:         $PROJECT_DIR"
  echo "  Skills:          $PROJECT_DIR/.claude/skills/"
fi
echo ""
echo "Next steps:"
echo "  1. Open your project's CLAUDE.md and fill in [CUSTOMIZE] sections"
echo "  2. Review .claude/hooks/ scripts — adjust test commands for your stack"
echo "  3. Start a Claude Code session and verify the session-start hook fires"
echo "  4. Create your first task: docs/tasks/open/my-first-task.md"
echo ""
echo "Documentation:"
echo "  README.md          — Full guide (in this starter kit)"
echo "  docs/WORKFLOW.md   — Workflow reference (in your project)"
echo "  templates/          — All templates for reference"
echo ""
