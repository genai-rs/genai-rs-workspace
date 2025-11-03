# Just Task Reference

The `Justfile` at the workspace root orchestrates editor launches, worktree helpers, and common utilities. These notes capture the features we rely on most heavily; they are all documented in the official manual at <https://just.systems/man/en/introduction.html> (see section *1.6 Features* for a concise overview).

## Core Patterns We Use

- **Global variables with `:=`**  
  `workspace-root := justfile_directory()` caches the root path once so every recipe can interpolate `{{workspace-root}}` without repeating shell logic.

- **Private helper recipes**  
  Prefixing with `#[private]` keeps helpers such as `_select-worktree` and `_require-worktree` out of `just --list` while still available for delegation.

- **Shebang-backed recipes**  
  Most helpers start with `#!/usr/bin/env bash` which lets us write multi-line shell scripts, benefit from `set -euo pipefail`, and call other tools.

- **String interpolation**  
  Interpolations like `{{workspace-root}}` and inline expressions `{{ if ... }}` allow lightweight branching without extra shell code.

- **Optional and variadic parameters**  
  Recipes such as `wt tool worktree=""` treat the trailing argument as optional; `wop *args` forwards any remaining tokens directly to `wt`.

- **Quiet commands with `@`**  
  Using `@just ...` prevents the invocation from being echoed, which keeps shortcuts like `wop` from printing redundant command lines.

## Practical Tips

- Prefer delegating to other recipes (`just wt ...`) instead of shelling out repeatedly; the manual covers dependencies, aliases, and recipe default values.
- When introducing new helpers, keep the shell logic centralized in `_select-worktree` / `_require-worktree` so optional arguments continue to “just work”.
- Section 1.6 of the manual also highlights features we have not needed yet (dependencies, exports, dry runs, etc.); skim it before adding advanced patterns to ensure we align with idiomatic Just usage.

## Further Reading

- Official manual: <https://just.systems/man/en/introduction.html>
- Conditional expressions and interpolation: <https://just.systems/man/en/modules/prelude.html>
- Recipe parameters and defaults: <https://just.systems/man/en/chapter_51.html>
