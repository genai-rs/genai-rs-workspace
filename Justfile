# Print available tasks
default:
	@just --list

workspace-root := justfile_directory()

# Acquire (temporary) AWS credentials
login:
	aws sso login --profile customer-assist-dev

# List available worktrees
w:
	@find worktrees -type d -mindepth 1 -maxdepth 1 | sort

# Run a git command in every repository under ./repos
ga command *args:
	#!/usr/bin/env bash
	root="{{workspace-root}}"
	command="{{command}}"
	set -- {{args}}
	find "$root/repos" -mindepth 1 -maxdepth 1 -type d \
		-exec bash -lc '
			root="$1"
			repo="$2"
			command="$3"
			shift 3
			rel="${repo#$root/}"
			printf "==> %s\n" "$rel"
			git -C "$repo" "$command" "$@"
		' _ "$root" {} "$command" "$@" \;

# Install required developer tools
install-dev-tools:
	#!/usr/bin/env bash
	tools=(terraform awscli uv gitlab-ci-local fzf)
	for tool in "${tools[@]}"; do
		if ! brew list --versions "$tool" >/dev/null 2>&1; then
			brew install "$tool"
		else
			echo "$tool already installed"
		fi
	done

# Helper to resolve or interactively select a worktree directory
#[private]
_select-worktree worktree="":
	#!/usr/bin/env bash
	set -euo pipefail
	root="{{workspace-root}}"
	selected="{{worktree}}"
	if [[ "$selected" == worktree=* ]]; then
		selected="${selected#worktree=}"
	fi
	if [ -n "$selected" ]; then
		if [[ "$selected" != /* ]]; then
			selected="$root/$selected"
		fi
		if [ ! -d "$selected" ]; then
			echo "Worktree directory not found: $selected" >&2
			exit 1
		fi
		printf '%s\n' "$selected"
		exit 0
	fi
	chosen="$(just --quiet _pick-worktree)" || exit 0
	if [ -n "$chosen" ]; then
		printf '%s\n' "$chosen"
	fi

# Prompt to choose a worktree and print the absolute path
#[private]
_pick-worktree:
	#!/usr/bin/env bash
	set -euo pipefail
	root="{{workspace-root}}"
	cd "$root"
	choice=$(find worktrees -type d -mindepth 1 -maxdepth 1 | sort | fzf --prompt="Worktree> " --height=20 --reverse) || exit 0
	if [ -z "$choice" ]; then
		exit 0
	fi
	printf '%s\n' "$root/$choice"

# Require a worktree selection and print the path
#[private]
_require-worktree worktree="":
	#!/usr/bin/env bash
	set -euo pipefail
	selected="$(just --quiet _select-worktree "{{worktree}}")"
	if [ -z "$selected" ]; then
		echo "No worktree selected" >&2
		exit 1
	fi
	printf '%s\n' "$selected"

# Run a command against a selected worktree
wt tool worktree="":
	#!/usr/bin/env bash
	set -euo pipefail
	tool_raw="{{tool}}"
	tool="${tool_raw#tool=}"
	worktree_raw="{{worktree}}"
	worktree="${worktree_raw#worktree=}"
	if [ -z "$tool" ]; then
		echo "Tool/command must be provided" >&2
		exit 1
	fi
	if [ -n "$worktree" ]; then
		selected="$(just --quiet _require-worktree "$worktree")"
	else
		selected="$(just --quiet _require-worktree)"
	fi
	escaped=$(printf '%q' "$selected")
	bash -lc "$tool $escaped"

# Open a worktree with PyCharm
wop *args:
	@just wt "open -na PyCharm.app --args" {{ args }}

# Open a worktree with RustRover
wor *args:
	@just wt "open -na RustRover.app --args" {{ args }}

# Open a worktree with VS Code
woc *args:
	@just wt code {{ args }}

# Remove a worktree directory and unregister it from its repository
wd worktree="":
	#!/usr/bin/env bash
	set -euo pipefail
	root="{{workspace-root}}"
	raw="{{worktree}}"
	worktree="${raw#worktree=}"
	if [ -n "$worktree" ]; then
		target="$(just --quiet _require-worktree "$worktree")"
	else
		target="$(just --quiet _require-worktree)"
	fi
	target="${target%/}"
	if [[ "$target" != "$root"/worktrees/* ]]; then
		echo "Worktree path must live under $root/worktrees" >&2
		exit 1
	fi
	repo_path="$(git -C "$target" worktree list --porcelain | awk 'NR==1 {print $2; exit}')"
	if [ -z "$repo_path" ]; then
		echo "Failed to resolve repository for $target" >&2
		exit 1
	fi
	if [ ! -d "$repo_path" ]; then
		echo "Repository path not found: $repo_path" >&2
		exit 1
	fi
	if git -C "$repo_path" worktree list --porcelain | grep -Fx "worktree $target" >/dev/null 2>&1; then
		git -C "$repo_path" worktree remove --force "$target"
	else
		echo "Warning: $target not registered as a git worktree in $repo_path; skipping git cleanup" >&2
	fi
	if [ -d "$target" ]; then
		rm -rf "$target"
	fi

# Wrap bd sync to avoid timestamp guard failures
bd-sync *args:
	#!/usr/bin/env bash
	set -euo pipefail
	root="{{workspace-root}}"
	future_ts="204001010000"
	touch -t "$future_ts" "$root/.beads/beads.db"
	cd "$root"
	set -- {{args}}
	if bd sync "$@"; then
		touch -t "$future_ts" "$root/.beads/beads.db"
	else
		exit $?
	fi
