#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function show_help() {
  cat <<EOF
Worktree Helper - Manage git worktrees for beads issues

Usage: $0 <command> [options]

Commands:
  list                List all active worktrees
  create <issue-id>   Create a new worktree for an issue
  remove <issue-id>   Remove a worktree
  clean               Remove all worktrees that have been merged
  status              Show status of all worktrees

Examples:
  $0 list
  $0 create genai-rs-42
  $0 remove genai-rs-42
  $0 clean

EOF
}

function list_worktrees() {
  echo -e "${BLUE}Active worktrees:${NC}"
  echo ""

  if [ ! -d "worktrees" ] || [ -z "$(ls -A worktrees 2>/dev/null)" ]; then
    echo "No active worktrees found."
    return
  fi

  for worktree in worktrees/*; do
    if [ -d "$worktree" ]; then
      basename "$worktree"
    fi
  done
}

function create_worktree() {
  local issue_id=$1

  if [ -z "$issue_id" ]; then
    echo -e "${RED}Error: Issue ID required${NC}"
    echo "Usage: $0 create <issue-id>"
    exit 1
  fi

  # Interactive repo selection
  echo -e "${BLUE}Select repository:${NC}"
  repos=(
    "genai-ci-bot"
    "langfuse-client-base"
    "langfuse-ergonomic"
    "langgraph-rs"
    "openai-client-base"
    "openai-ergonomic"
    "opentelemetry-langfuse"
    "rmcp-demo"
    "demo"
  )

  select repo in "${repos[@]}"; do
    if [ -n "$repo" ]; then
      break
    fi
  done

  # Get description
  read -p "Short description (kebab-case): " description

  # Build worktree name
  worktree_name="${issue_id}-${repo}-${description}"
  worktree_path="worktrees/${worktree_name}"

  if [ -d "$worktree_path" ]; then
    echo -e "${RED}Error: Worktree already exists: $worktree_path${NC}"
    exit 1
  fi

  repo_path="repos/$repo"

  if [ ! -d "$repo_path" ]; then
    echo -e "${RED}Error: Repository not found: $repo_path${NC}"
    exit 1
  fi

  # Navigate to repo and create worktree
  echo ""
  echo -e "${YELLOW}Pulling latest changes from origin/main...${NC}"
  cd "$repo_path"
  git checkout main
  git pull origin main

  echo -e "${YELLOW}Creating worktree: $worktree_name${NC}"
  git worktree add "../../${worktree_path}" -b "$worktree_name"

  cd ../..
  echo ""
  echo -e "${GREEN}✓ Worktree created successfully!${NC}"
  echo ""
  echo "Next steps:"
  echo "  cd $worktree_path"
  echo "  # Make your changes"
  echo "  git add ."
  echo "  git commit -m \"Fix: description ($issue_id)\""
  echo "  git push -u origin $worktree_name"
  echo ""
}

function remove_worktree() {
  local issue_id=$1

  if [ -z "$issue_id" ]; then
    echo -e "${RED}Error: Issue ID required${NC}"
    echo "Usage: $0 remove <issue-id>"
    exit 1
  fi

  # Find worktree matching issue ID
  worktree=$(find worktrees -maxdepth 1 -type d -name "${issue_id}-*" | head -n 1)

  if [ -z "$worktree" ]; then
    echo -e "${RED}Error: No worktree found for issue: $issue_id${NC}"
    exit 1
  fi

  worktree_name=$(basename "$worktree")

  echo -e "${YELLOW}Removing worktree: $worktree_name${NC}"

  # Extract repo name from worktree name (pattern: issue-id-repo-description)
  # This is a simple heuristic - assumes second segment is repo name
  repo=$(echo "$worktree_name" | cut -d'-' -f3)
  repo_path="repos/$repo"

  if [ -d "$repo_path" ]; then
    cd "$repo_path"

    # Remove worktree
    git worktree remove "../../$worktree"

    # Ask about branch deletion
    read -p "Delete branch $worktree_name locally? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      git branch -d "$worktree_name" 2>/dev/null || git branch -D "$worktree_name"
      echo -e "${GREEN}✓ Local branch deleted${NC}"
    fi

    # Ask about remote branch deletion
    if git ls-remote --exit-code --heads origin "$worktree_name" >/dev/null 2>&1; then
      read -p "Delete branch $worktree_name from remote? [y/N] " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push origin --delete "$worktree_name"
        echo -e "${GREEN}✓ Remote branch deleted${NC}"
      fi
    fi

    cd ../..
  fi

  echo -e "${GREEN}✓ Worktree removed successfully!${NC}"
}

function clean_worktrees() {
  echo -e "${BLUE}Checking for merged worktrees...${NC}"
  echo ""

  if [ ! -d "worktrees" ] || [ -z "$(ls -A worktrees 2>/dev/null)" ]; then
    echo "No worktrees to clean."
    return
  fi

  merged_count=0

  for worktree in worktrees/*; do
    if [ ! -d "$worktree" ]; then
      continue
    fi

    worktree_name=$(basename "$worktree")

    # Extract repo name (heuristic)
    repo=$(echo "$worktree_name" | cut -d'-' -f3)
    repo_path="repos/$repo"

    if [ ! -d "$repo_path" ]; then
      echo -e "${YELLOW}⚠️  Repository not found for $worktree_name, skipping${NC}"
      continue
    fi

    cd "$repo_path"

    # Check if branch is merged into main
    if git branch --merged main | grep -q "$worktree_name"; then
      echo -e "${GREEN}✓ $worktree_name is merged${NC}"
      git worktree remove "../../$worktree"
      git branch -d "$worktree_name" 2>/dev/null || true
      ((merged_count++))
    fi

    cd ../..
  done

  echo ""
  echo -e "${GREEN}Cleaned up $merged_count merged worktree(s)${NC}"
}

function show_status() {
  echo -e "${BLUE}Worktree status:${NC}"
  echo ""

  if [ ! -d "worktrees" ] || [ -z "$(ls -A worktrees 2>/dev/null)" ]; then
    echo "No active worktrees."
    return
  fi

  for worktree in worktrees/*; do
    if [ ! -d "$worktree" ]; then
      continue
    fi

    worktree_name=$(basename "$worktree")
    echo -e "${YELLOW}$worktree_name${NC}"

    cd "$worktree"

    # Show git status
    if git diff-index --quiet HEAD -- 2>/dev/null; then
      echo -e "  ${GREEN}✓ Clean${NC}"
    else
      echo -e "  ${RED}⚠ Uncommitted changes${NC}"
    fi

    # Show branch status relative to origin
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
      ahead=$(git rev-list --count @{u}..HEAD)
      behind=$(git rev-list --count HEAD..@{u})

      if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
        echo -e "  ${BLUE}↑ $ahead ahead, ↓ $behind behind${NC}"
      else
        echo -e "  ${GREEN}✓ Up to date with remote${NC}"
      fi
    else
      echo -e "  ${YELLOW}⚠ No upstream branch${NC}"
    fi

    cd - >/dev/null
    echo ""
  done
}

# Main command router
case "${1:-}" in
  list)
    list_worktrees
    ;;
  create)
    create_worktree "$2"
    ;;
  remove)
    remove_worktree "$2"
    ;;
  clean)
    clean_worktrees
    ;;
  status)
    show_status
    ;;
  help|--help|-h|"")
    show_help
    ;;
  *)
    echo -e "${RED}Error: Unknown command: $1${NC}"
    echo ""
    show_help
    exit 1
    ;;
esac
