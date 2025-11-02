# Release Automation Playbook

This guide explains how release automation works across the genai-rs organization and what to do when you need to cut a new version (for example, bumping `openai-client-base` to `0.8.0`).

## Overview

- Releases are driven by [`release-plz`](https://release-plz.ieni.dev/). Each repository contains a `.github/workflows/release-plz.yml` workflow that runs after changes land on `main`.
- The workflow uses the organization GitHub App (`BOT_APP_ID`/`BOT_PRIVATE_KEY`) to authenticate and to ensure CI runs on the automation branches.
- Publishing to crates.io happens automatically once the workflow completes, using the `CARGO_REGISTRY_TOKEN` secret stored in the repository.
- The action tags the release (`v<version>`), creates the GitHub Release with notes from the changelog, and pushes any generated files back to the repository if needed.

## Prerequisites

- Ensure the repository has the three secrets configured: `BOT_APP_ID`, `BOT_PRIVATE_KEY`, and `CARGO_REGISTRY_TOKEN`.
- Confirm the `release-plz.toml` file is under version control and includes the desired publish/tag settings.
- CI (`ci.yml`) must pass on the release PR before merging; the automation will not override failing checks.

## Typical Workflow

1. **Wait for the automated release PR**  
   `release-plz` monitors `main` and periodically opens a PR named `chore: release version <version>`. The branch lives under `automated/release-plz/…`.

2. **Adjust the version if necessary**  
   - If you want to publish `0.8.0` instead of the proposed `0.7.1`, edit `Cargo.toml` (and regenerate `Cargo.lock` if present) in the PR branch to the desired semver.
   - Update `CHANGELOG.md` so the heading reflects the final version (`## [0.8.0]`) and the compare link points to `.../compare/v0.7.0...v0.8.0`.
   - Keep the release commit aligned with the new version. Either amend the existing release commit (`git commit --amend -m "chore: release version <version>"`) to retain the single automation commit, or create a follow-up commit with a clear message (e.g. `chore: adjust release to 0.8.0`).
   - Run `cargo fmt`, `cargo check`, and any other relevant checks locally.

3. **Review and merge the PR**  
   - Confirm CI is green (stable/beta/MSRV builds, fmt, clippy).  
   - Merge normally once content looks correct.

4. **Monitor the release workflow**  
   - After merging, the `Release-plz` GitHub Action runs on `main`.  
   - Watch the workflow logs to ensure publishing succeeds. The summary will include links to the crate release and GitHub tag.

5. **Verify publication**  
   - Check crates.io for the new version.  
   - Confirm the GitHub release shows the correct changelog excerpt and assets (if any).

## Troubleshooting

- **Workflow fails before publish**: Fix the underlying issue (e.g., missing secrets, cargo publish error), push a commit to `main`, and the workflow will re-run automatically.
- **Need to rerun publish**: Use the "Re-run workflow" button on GitHub after resolving the failure.
- **Accidental version bump**: Revert the merge or open a new PR adjusting the version and changelog; the next merge will republish under the corrected version.

## When Manual Steps Are Required

- `release-plz` only handles repositories configured with the workflow and `release-plz.toml`. For other repos, follow their local release instructions.
- If you need to ship emergency fixes after a release fails, create a new release PR (manually or by re-running release-plz) to ensure automation takes over again.
