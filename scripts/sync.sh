#!/bin/bash
set -e

echo "🔄 Syncing all genai-rs repositories..."
echo ""

# List of repository directories
repos=(
  "genai-ci-bot"
  "langfuse-client-base"
  "langfuse-ergonomic"
  "langgraph-rs"
  "openai-client-base"
  "openai-ergonomic"
  "opentelemetry-langfuse"
  "rmcp-demo"
  "dot-github"
  "demo"
)

failed_repos=()

for repo in "${repos[@]}"; do
  if [ ! -d "$repo" ]; then
    echo "⚠️  $repo: directory not found, skipping..."
    continue
  fi

  if [ ! -d "$repo/.git" ]; then
    echo "⚠️  $repo: not a git repository, skipping..."
    continue
  fi

  echo "📥 Syncing $repo..."

  # Change to repo directory
  cd "$repo"

  # Get current branch
  current_branch=$(git branch --show-current)

  # Check if we're on a branch (not detached HEAD)
  if [ -z "$current_branch" ]; then
    echo "   ⚠️  Detached HEAD state, skipping pull"
    cd ..
    continue
  fi

  # Check for uncommitted changes
  if ! git diff-index --quiet HEAD --; then
    echo "   ⚠️  Uncommitted changes detected, skipping pull"
    cd ..
    failed_repos+=("$repo (uncommitted changes)")
    continue
  fi

  # Pull latest changes
  if git pull --ff-only origin "$current_branch" 2>/dev/null; then
    echo "   ✓ Updated successfully"
  else
    # Try to fetch at least
    if git fetch origin 2>/dev/null; then
      echo "   ⚠️  Fetched but couldn't fast-forward, manual merge may be needed"
      failed_repos+=("$repo (needs manual merge)")
    else
      echo "   ❌ Failed to sync"
      failed_repos+=("$repo (sync failed)")
    fi
  fi

  cd ..
  echo ""
done

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ${#failed_repos[@]} -eq 0 ]; then
  echo "✅ All repositories synced successfully!"
else
  echo "⚠️  Some repositories need attention:"
  for repo in "${failed_repos[@]}"; do
    echo "   - $repo"
  done
fi
echo ""
