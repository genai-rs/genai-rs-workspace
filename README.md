# GenAI-RS Workspace

**Multi-repository workspace for the genai-rs GitHub organization**

This repository provides a unified workspace for developing across all genai-rs projects. It contains organization-wide documentation, tooling, and automation scripts while each project repository remains independent.

**Organization**: https://github.com/genai-rs

## Quick Start

### Initial Setup

```bash
# Clone this workspace repository
git clone git@github.com:genai-rs/genai-rs-workspace.git genai-rs
cd genai-rs

# Run setup script to clone all project repositories
./scripts/setup.sh
```

This will create a directory structure with all genai-rs repositories:

```
genai-rs/
├── AGENTS.md              # AI agent development guidelines
├── CLAUDE.md              # Claude-specific reference
├── README.md              # This file
├── .beads/                # Beads issue tracking
│   └── issues.jsonl       # Committed source of truth
├── scripts/               # Automation utilities
│   ├── setup.sh          # Initial workspace setup
│   ├── sync.sh           # Pull all repositories
│   └── worktree-helper.sh # Worktree management
├── worktrees/            # Per-issue git worktrees
│
# Independent repositories (gitignored, cloned into repos/ by setup.sh):
└── repos/
    ├── genai-ci-bot/
    ├── langfuse-client-base/
    ├── langfuse-ergonomic/
    ├── langgraph-rs/
    ├── openai-client-base/
    ├── openai-ergonomic/
    ├── opentelemetry-langfuse/
    ├── rmcp-demo/
    ├── dot-github/
    └── demo/              # Local-only (copy manually if needed)
```

## Projects

| Repository | Description | GitHub |
|------------|-------------|--------|
| `demo` | OpenAI tool calling showcase with Langfuse tracing | Local only |
| `genai-ci-bot` | GitHub App for minting short-lived CI tokens | https://github.com/genai-rs/genai-ci-bot |
| `langfuse-client-base` | Auto-generated low-level Langfuse API client | https://github.com/genai-rs/langfuse-client-base |
| `langfuse-ergonomic` | High-level Langfuse client with builder APIs | https://github.com/genai-rs/langfuse-ergonomic |
| `langgraph-rs` | LangGraph Python to Rust transpiler | https://github.com/genai-rs/langgraph-rs |
| `openai-client-base` | Auto-generated OpenAI API bindings | https://github.com/genai-rs/openai-client-base |
| `openai-ergonomic` | Ergonomic OpenAI wrapper with streaming | https://github.com/genai-rs/openai-ergonomic |
| `opentelemetry-langfuse` | Langfuse OpenTelemetry exporter | https://github.com/genai-rs/opentelemetry-langfuse |
| `rmcp-demo` | Rust MCP HTTP server demo | https://github.com/genai-rs/rmcp-demo |
| `dot-github` | Organization profile README | https://github.com/genai-rs/.github |

## Development Workflow

This workspace uses **git worktrees** + **Beads** for issue-based development:

```bash
# Find available issues
bd ready

# Start work on an issue
bd update <issue-id> --status in_progress

# Create worktree for isolated work
cd repos/<target-repo>
git checkout main
git pull origin main
git worktree add ../../worktrees/<issue-id>-<repo>-<description> -b <issue-id>-<repo>-<description>
cd ../../worktrees/<issue-id>-<repo>-<description>

# Make changes, commit, create PR
git add .
git commit -m "Fix: description (issue-id)"
git push -u origin <branch-name>
gh pr create --title "<issue-id>: title" --body "Closes <issue-id>"

# Wait for CI and merge, then close issue
gh pr checks
bd close <issue-id> --reason "PR merged"

# Clean up
cd ../..
git worktree remove worktrees/<issue-id>-<repo>-<description>
```

See [AGENTS.md](AGENTS.md) for complete workflow documentation.

## Common Commands

```bash
# Update all repositories
./scripts/sync.sh

# Beads issue management
bd ready                          # Find available work
bd list --status open             # List open issues
bd create "Title" --type feature  # Create new issue
bd show <issue-id>                # Show issue details
bd close <issue-id>               # Close completed issue

# Worktree management
git worktree list                 # List all worktrees
./scripts/worktree-helper.sh      # Interactive worktree utilities
```

## For AI Agents

This workspace is designed to be AI-agent friendly:

- **Read [AGENTS.md](AGENTS.md)** for complete guidelines
- Always pull latest before creating worktrees
- Use Beads to track all work
- Create cleanup tasks for completed issues
- Never include promotional messages in commits/PRs

## Documentation

- **[AGENTS.md](AGENTS.md)** - Complete development workflow and agent guidelines
- **[CLAUDE.md](CLAUDE.md)** - Claude Code reference (redirects to AGENTS.md)
- **`.beads/issues.jsonl`** - Beads issue tracking source of truth

## Maintenance

This workspace repository tracks:
- Organization-wide documentation
- Automation scripts
- Beads issue history (`.beads/issues.jsonl`)
- Empty `docs/` directory for shared documentation

It **does not** track:
- Individual project repositories (gitignored in `repos/`)
- Worktrees (created locally per developer)
- Beads SQLite cache (local only)

## Contributing

1. Clone this workspace and run `./scripts/setup.sh`
2. Check `bd ready` for available issues
3. Follow the worktree workflow in [AGENTS.md](AGENTS.md)
4. Keep commits focused and CI green

## License

See individual project repositories for their respective licenses.

---

**Maintained by**: AI agents and human developers working on genai-rs projects
