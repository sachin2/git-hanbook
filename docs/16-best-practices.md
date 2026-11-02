# 16 · Best Practices

## Commits

- **Atomic:** one logical change per commit. If the message needs "and", it's probably two commits.
- **Buildable:** every commit should compile/elaborate and pass fast tests — this makes `git bisect` and reverts reliable.
- **Small and frequent locally; polished before sharing.** Commit WIP freely on your branch, then clean up with interactive rebase / autosquash before opening the PR.
- **Stage deliberately** with `git add -p`; never commit what you haven't reviewed with `git diff --staged`.
- **Separate formatting/renames from logic changes.** Reviewers can then skim the mechanical commit and focus on the real one.
- **Don't commit commented-out code, debug prints or personal TODOs.**

## Commit messages

```
<Imperative summary, ≤ 50 chars>

<Why this change is needed. What problem it solves. Any side effects,
trade-offs, or alternatives considered. Wrap at 72 columns.>

Refs: #123
```

Good: `Fix CDC handshake losing a request on back-to-back writes`
Bad: `fix`, `update`, `changes`, `WIP`, `asdf`, `final version 2`

A future reader (often you) uses `git log` and `git blame` to understand *why* code is the way it is. The message is the only place that knowledge survives.

## Branches

- Short-lived (days, not months). Long-lived branches drift and produce painful merges.
- Rebase your feature branch on `main` regularly (or merge `main` into it if it's shared).
- Delete branches after merging (`git branch -d`, and enable "auto-delete head branches" on the server).
- Descriptive names: `fix/fifo-overflow`, not `test2`.
- Protect `main`; everything goes through review + CI.

## Sharing / history

- **Never rewrite published shared history.** `revert` instead of `reset` on shared branches.
- **`--force-with-lease`**, never `--force`.
- **Fetch first, look, then integrate.**
- Pull with rebase on your own branches to avoid merge noise.
- Tag every release / tapeout / delivered bitstream with an annotated tag.

## Repository hygiene

- Create `.gitignore` and `.gitattributes` **before** the first commit.
- Never commit: secrets, credentials, build outputs, generated files, IDE settings that are user-specific, large binaries (use LFS or an artefact store), vendor/PDK files you aren't licensed to redistribute.
- Keep a `README.md` explaining how to build/run/test.
- Commit a lockfile / tool-version file so builds are reproducible.
- Use `CODEOWNERS`, branch protection, PR templates.
- Run secret scanning and a pre-commit hook.
- Keep repos out of cloud-sync folders.

## Safety habits

- `git status` constantly.
- Before risky operations: `git branch backup/before-rebase`.
- Preview destructive commands: `git clean -n`, `git push --dry-run`, `git reset --keep` rather than `--hard`.
- Know `git reflog` exists — it turns most panics into a 30-second fix.
- Push your branch to the remote at least daily — your laptop is not a backup.

## Review

- PRs small and focused; description explains why and how to verify.
- Review your own diff first on the web UI — you'll catch half the issues.
- Require CI green before merge.
- Squash vs. merge vs. rebase: choose one per repo and stick to it.

## Performance with large repositories

- `git clone --filter=blob:none` and sparse-checkout.
- `git maintenance start` (background commit-graph, prefetch, repack).
- `core.fsmonitor` and `core.untrackedCache` for faster `status`.
- `git gc` occasionally on very old clones (`git count-objects -vH` to check size).

## Next

→ [17 · Git for hardware / EDA projects](17-git-for-hardware-projects.md)
