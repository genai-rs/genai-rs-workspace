#!/bin/bash
set -e

echo "🔧 Setting up genai-rs workspace..."
echo ""

# Repository list with metadata
declare -A repos=(
  ["genai-ci-bot"]="GitHub App for minting short-lived CI tokens"
  ["langfuse-client-base"]="Auto-generated low-level Langfuse API client"
  ["langfuse-ergonomic"]="High-level Langfuse client with builder APIs"
  ["langgraph-rs"]="LangGraph Python to Rust transpiler"
  ["openai-client-base"]="Auto-generated OpenAI API bindings"
  ["openai-ergonomic"]="Ergonomic OpenAI wrapper with streaming"
  ["opentelemetry-langfuse"]="Langfuse OpenTelemetry exporter"
  ["rmcp-demo"]="Rust MCP HTTP server demo"
  [".github"]="Organization profile README"
)

# Clone repositories
for repo in "${!repos[@]}"; do
  target_dir="$repo"
  # Handle .github special case (cloned as dot-github locally)
  if [ "$repo" = ".github" ]; then
    target_dir="dot-github"
  fi

  if [ -d "$target_dir" ]; then
    echo "✓ $repo already exists, skipping..."
  else
    echo "📦 Cloning $repo..."
    echo "   ${repos[$repo]}"

    if [ "$repo" = ".github" ]; then
      git clone "git@github.com:genai-rs/$repo.git" "$target_dir"
    else
      git clone "git@github.com:genai-rs/$repo.git"
    fi
    echo ""
  fi
done

# Create worktrees directory
if [ ! -d "worktrees" ]; then
  echo "📁 Creating worktrees directory..."
  mkdir -p worktrees
fi

# Check if demo exists (local-only repo)
if [ ! -d "demo" ]; then
  echo ""
  echo "⚠️  Note: 'demo' directory not found."
  echo "   This is a local-only repository with no remote configured."
  echo "   If you have it elsewhere, copy it manually."
fi

echo ""
echo "✅ Workspace setup complete!"
echo ""
echo "Next steps:"
echo "  1. Check available issues: bd ready"
echo "  2. Read development guidelines: cat AGENTS.md"
echo "  3. Start working on an issue following the worktree workflow"
echo ""
