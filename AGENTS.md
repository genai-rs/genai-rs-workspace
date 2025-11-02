# GenAI-RS Agent Instructions

## Project Overview

This repository serves as the **meta-repository** for the **genai-rs GitHub organization**. It contains multiple Rust projects focused on ergonomic GenAI client libraries, tool frameworks, and related infrastructure.

**Organization**: https://github.com/genai-rs

## Repository Structure

The meta checkout itself is **not** a Git repository; each child folder is an independent clone with its own `.git` directory. Use this index to jump into the right project:

| Folder | Summary | GitHub |
| --- | --- | --- |
| `demo` | Showcase of OpenAI tool calling in Rust with Langfuse tracing and companion tool framework docs. | local-only (no remote configured) |
| `genai-ci-bot` | Configuration and helper scripts for the GitHub App that mints short-lived CI tokens across the org. | https://github.com/genai-rs/genai-ci-bot |
| `langfuse-client-base` | Auto-generated, low-level Langfuse API client produced from the official OpenAPI specification. | https://github.com/genai-rs/langfuse-client-base |
| `langfuse-ergonomic` | High-level Langfuse client offering builder APIs, batching, retries, and ergonomic configuration helpers. | https://github.com/genai-rs/langfuse-ergonomic |
| `langgraph-rs` | Transpiler and runtime that turns LangGraph Python workflows into optimized Rust implementations. | https://github.com/genai-rs/langgraph-rs |
| `openai-client-base` | Auto-generated OpenAI API bindings that act as the foundation for higher-level client crates. | https://github.com/genai-rs/openai-client-base |
| `openai-ergonomic` | Ergonomic OpenAI wrapper with builder patterns, streaming support, and Azure OpenAI compatibility. | https://github.com/genai-rs/openai-ergonomic |
| `opentelemetry-langfuse` | Langfuse exporter plus utilities for forwarding OpenTelemetry traces from LLM applications. | https://github.com/genai-rs/opentelemetry-langfuse |
| `rmcp-demo` | Rust MCP HTTP server demo featuring Langfuse + OpenTelemetry instrumentation and a FastMCP client. | https://github.com/genai-rs/rmcp-demo |

## Key Directories

- **`.beads/`** – Beads issue-tracking storage. The SQLite cache (`genai-rs.db`) is local-only; the committed `issues.jsonl` is the shared source of truth. Never hand-edit the JSONL—always use `bd`.
- **`dot-github/`** – Organization metadata repository. Contains the profile README that appears on https://github.com/genai-rs. Update it here when changing org-wide presentation.
- **`worktrees/`** – Per-issue git worktrees. Use the naming convention in the workflow below so each subfolder maps cleanly back to an issue + repository.

## Issue Tracking with Beads

This project uses **Beads** (https://github.com/steveyegge/beads), an AI-friendly issue tracking system designed for coding agents.

### Beads Workflow

**Managing Issues:**
```bash
bd create "Issue title" --type feature --priority 2
bd list --status open
bd ready                    # Find issues ready to work on
bd blocked                  # Show blocked issues
bd update <id> --status in_progress
bd close <id> --reason "Completed"
```

Whenever you create an issue, include the target repository in the title (for example, `openai-ergonomic: Document streaming helpers`). This makes the open-work listings actionable even without additional context.

**Key Concepts:**
- **Graph-based dependencies**: Issues chain together like beads
- **Distributed via Git**: SQLite cache (local) + JSONL source of truth (committed)
- **Auto-sync**: 5-second debounce keeps machines synchronized
- **Agent-friendly**: JSON queries, audit trails, no context amnesia

### Dependency Types

- `blocks` - Hard blocker preventing work
- `related` - Soft connection between issues
- `parent-child` - Hierarchical relationship
- `discovered-from` - Issue found during other work

## Worktree-Based Development Workflow

When starting work on a beads issue, follow this workflow:

### 1. Starting Work on an Issue

```bash
# Find ready work
bd ready

# Update issue status
bd update <issue-id> --status in_progress

# IMPORTANT: Pull latest changes from origin/main before creating worktree
cd repos/<target-repo-folder>
git checkout main
git pull origin main

# Create worktree for the issue
git worktree add ../../worktrees/<issue-id>-<repo>-<slug> -b <issue-id>-<repo>-<slug>
cd ../../worktrees/<issue-id>-<repo>-<slug>

# Work on the issue...
```

Use the repository directory (e.g., `openai-ergonomic`) for `<repo>` so worktree folders stay searchable (`genai-rs-1-openai-ergonomic-docs` is much easier to grep later).

### 2. During Development

- Keep all analysis documents, screenshots, downloads in the worktree folder
- Use the beads CLI to update issue status and track blockers
- File discovered issues with `bd create` and link via `bd dep <from> <to> --type discovered-from`

### 3. Completing Work

```bash
# Commit and push changes
git add .
git commit -m "Fix: <description> (<issue-id>)"
# IMPORTANT: Do NOT include promotional messages like "🤖 Generated with Claude Code"
# in commit messages, PR descriptions, or code comments
git push -u origin <branch-name>

# Create PR if needed
gh pr create --title "<issue-id>: <title>" --body "Closes <issue-id>"
# IMPORTANT: Keep PR descriptions focused and professional - no promotional content

# IMPORTANT: Wait for CI checks to pass and PR to be merged
# Monitor CI status with:
gh pr view <pr-number> --repo <org>/<repo>
gh pr checks <pr-number> --repo <org>/<repo>

# Only close the beads issue AFTER:
# 1. All CI checks have passed
# 2. PR has been reviewed and approved (if required)
# 3. PR has been merged to the target branch
bd close <issue-id> --reason "PR merged" # or "Completed"
```

**Completion checklist:**
- [ ] Code committed and pushed to branch
- [ ] PR created with proper title and description
- [ ] All CI checks passing
- [ ] PR reviewed and approved (if required)
- [ ] PR merged to target branch
- [ ] Beads issue closed
- [ ] Cleanup initiated (see section 4)

### 4. Cleanup Process

**After issue completion:**

```bash
# Navigate back to workspace root
cd /Users/tim.van.wassenhove/src/genai-rs

# Remove worktree
cd repos/<target-repo-folder>
git worktree remove ../../worktrees/<issue-id>-<descriptive-name>

# Delete the branch (if merged)
git branch -d <issue-id>-<descriptive-name>

# Clean up remote branch (if applicable)
git push origin --delete <issue-id>-<descriptive-name>
```

**Cleanup checklist:**
- [ ] Remove worktree directory
- [ ] Delete local branch
- [ ] Delete remote branch (if merged)
- [ ] Remove any temporary analysis documents
- [ ] Remove screenshots/downloads created during investigation
- [ ] Close beads issue

### 5. Automated Cleanup Tasks

When closing an issue, **consider creating a cleanup task**:

```bash
bd create "Cleanup worktree for <issue-id>" \
  --type chore \
  --priority 3 \
  --dep <issue-id> --dep-type discovered-from
```

This ensures cleanup happens systematically and is tracked.

## Agent Guidelines

### For AI Coding Agents

1. **Always check beads first**: Run `bd ready` to find available work
2. **Update issue status**: Move to `in_progress` when starting
3. **Pull before starting**: Always `git pull origin main` before creating a worktree to ensure you're working with the latest code
4. **Use worktrees**: Create isolated environments for each issue
5. **File discovered issues**: Don't let context slip - create issues immediately
6. **Link dependencies**: Use `bd dep` to maintain the issue graph
7. **Wait for CI and merge**: After creating a PR, monitor CI checks and wait for the PR to be merged before closing the issue. Use `gh pr checks` and `gh pr view` to monitor status.
8. **Close only after merge**: Mark issues complete with `bd close` only after all CI checks pass and the PR is merged
9. **Clean up**: Remove worktrees and temporary files after completion
10. **Communicate availability clearly**: When sharing `bd ready` results, omit issues already assigned/in progress or explicitly call out their status so others know they aren't available to pick up.

### Context Preservation

Beads acts as **long-term memory across sessions**:
- Issues persist even after agent restarts
- Dependency graph maintains relationships
- Audit trail shows what happened and when
- JSON queryable for agent consumption

## Development Philosophy

- **Ergonomic APIs**: Prioritize developer experience
- **Type safety**: Leverage Rust's type system
- **Async-first**: All APIs support async/await
- **Tool frameworks**: Make LLM tool calling easy
- **Observability**: Integrate with Langfuse/OpenTelemetry
- **AI-native**: Built with AI agents in mind

## Tooling Standards

### Python Package Management

**Use `uv` for all Python operations:**

```bash
# Install dependencies
uv sync --all-extras

# Run Python scripts
uv run python script.py

# Run Python tools (mypy, ruff, black, pytest, etc.)
uv run mypy src/
uv run ruff check .
uv run black --check .
uv run pytest
```

**Rationale:**
- `uv` manages virtual environments automatically
- Running `python` directly outside `uv run` may use system Python instead of project dependencies
- CI workflows must use `uv run` to ensure commands execute within the correct virtual environment
- Prevents `ModuleNotFoundError` for packages that are installed but not on PATH

**Projects using Python:**
- `langgraph-rs` - Python test fixtures and tooling

### Rust Dependency Management

**Use flexible SemVer ranges in `Cargo.toml`:**

```toml
# Good - allows consumers flexibility
tokio = { version = "^1.48", features = ["full"] }
serde = { version = "^1.0", features = ["derive"] }

# Avoid - too restrictive
tokio = "1.48.0"  # Locks to exact version
```

**Rationale:**
- Library crates should use flexible ranges to avoid version conflicts for consumers
- The `^` operator allows SemVer-compatible updates (`^1.2.3` means `>=1.2.3, <2.0.0`)
- Renovate with `rangeStrategy: 'bump'` keeps ranges updated automatically

## Common Commands

```bash
# Check project status
bd stats

# Find ready work
bd ready --priority 1

# List open issues
bd list --status open

# Show issue details
bd show <issue-id>

# Create new issue
bd create "Title" --type feature --priority 2

# Update issue
bd update <issue-id> --status in_progress --assignee "agent-name"

# Add dependency
bd dep <blocks-id> <blocked-id> --type blocks

# Close issue
bd close <issue-id> --reason "Completed"

# List worktrees
git worktree list

# Remove worktree
git worktree remove worktrees/<name>
```

## File Organization

```
genai-rs/
 .beads/              # Beads database
    genai-rs.db      # SQLite cache (gitignored)
    *.jsonl          # Source of truth (committed)
 repos/               # Cloned repositories (gitignored)
    genai-ci-bot/
    langfuse-*/
    openai-*/
    ...              # All project repos
 worktrees/           # Active issue worktrees (gitignored)
    <issue-id>-*/    # Individual worktree folders
 docs/                # Shared documentation
 scripts/             # Automation scripts
 AGENTS.md            # This file
 README.md            # Workspace documentation
```

## References

- **Beads**: https://github.com/steveyegge/beads
- **Organization**: https://github.com/genai-rs
- **Tool Framework**: See `docs/tool_framework.md`

---

**Last Updated**: 2025-10-21

**Maintained by**: AI agents and human developers working on genai-rs projects
