#!/bin/bash
set -e

echo "🔧 Setting up genai-rs workspace..."
echo ""

# Repository list - format: "repo_name|target_dir|description"
repos=(
  "genai-ci-bot|genai-ci-bot|GitHub App for minting short-lived CI tokens"
  "langfuse-client-base|langfuse-client-base|Auto-generated low-level Langfuse API client"
  "langfuse-ergonomic|langfuse-ergonomic|High-level Langfuse client with builder APIs"
  "langgraph-rs|langgraph-rs|LangGraph Python to Rust transpiler"
  "openai-client-base|openai-client-base|Auto-generated OpenAI API bindings"
  "openai-ergonomic|openai-ergonomic|Ergonomic OpenAI wrapper with streaming"
  "opentelemetry-langfuse|opentelemetry-langfuse|Langfuse OpenTelemetry exporter"
  "rmcp-demo|rmcp-demo|Rust MCP HTTP server demo"
  ".github|dot-github|Organization profile README"
)

# Clone repositories
for repo_info in "${repos[@]}"; do
  IFS='|' read -r repo target_dir description <<< "$repo_info"

  if [ -d "$target_dir" ]; then
    echo "✓ $repo already exists, skipping..."
  else
    echo "📦 Cloning $repo..."
    echo "   $description"

    git clone "git@github.com:genai-rs/$repo.git" "$target_dir"
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
