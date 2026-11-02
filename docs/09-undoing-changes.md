# 09 · Undoing Things

## Decision table: "I want to undo…"

| Situation | Command | Destroys work? |
|---|---|---|
| Unsaved edits in a file (not staged) | `git restore file` | ⚠ yes, those edits |
| All unstaged edits | `git restore .` | ⚠ yes |
| Staged a file by mistake | `git restore --staged file` | no |
| Last commit message is wrong | `git commit --amend` | no |
| Forgot a file in the last commit | `git add f && git commit --amend --no-edit` | no |
| Undo last commit, keep changes staged | `git reset --soft HEAD~1` | no |
| Undo last commit, keep changes unstaged | `git reset HEAD~1` (`--mixed`) | no |
| Throw away last commit entirely | `git reset --hard HEAD~1` | ⚠ yes (recoverable via reflog) |
| Undo a commit that's **already pushed** | `git revert <sha>` | no — adds an inverse commit |
| Undo a pushed merge commit | `git revert -m 1 <merge-sha>` | no |
| Restore a file to how it was 3 commits ago | `git restore --source=HEAD~3 file` | overwrites current file |
| Recover a deleted branch | `git reflog` → `git branch name <sha>` | no |
| Undo a bad rebase/reset | `git reset --hard ORIG_HEAD` or `HEAD@{n}` | ⚠ discards current state |
| Delete untracked files | `git clean -n` then `git clean -fd` | ⚠ yes, **not** recoverable |
| Committed to the wrong branch | see below | no |
| Abort an in-progress operation | `git merge --abort` / `rebase --abort` / `cherry-pick --abort` | no |

## `git restore` (files)

```bash
git restore file.c                       # working tree ← index
git restore --staged file.c              # index ← HEAD (unstage)
git restore --staged --worktree file.c   # both ← HEAD
git restore --source=main~2 file.c       # from any commit
git restore -p file.c                    # hunk by hunk
```

## `git reset` (move the branch pointer)

```
            moves branch   resets index   resets working tree
--soft          ✔               ✘                ✘
--mixed (def.)  ✔               ✔                ✘
--hard          ✔               ✔                ✔   ⚠
--keep          ✔               ✔           only if no local changes clash (safer --hard)
```

```bash
git reset --soft HEAD~3        # squash last 3 commits into staged changes, re-commit as one
git reset --hard origin/main   # make local branch identical to remote  ⚠
git reset --keep HEAD~1        # like --hard but refuses to destroy uncommitted edits
```

## `git revert` (safe undo for shared history)

```bash
git revert <sha>                     # new commit undoing <sha>
git revert --no-commit A..B          # revert a range, commit once
git revert -m 1 <merge-sha>          # revert a merge; -m 1 = keep mainline parent
```

> **Gotcha — reverting a merge, then re-merging the branch:** Git considers the branch's commits already merged, so re-merging brings in nothing. First **revert the revert** (`git revert <revert-sha>`), then merge the new fixes.

## The reflog — your safety net

Every time HEAD or a branch moves, Git logs it locally.

```bash
git reflog                       # HEAD history
git reflog show feature          # one branch's history
git reflog --date=iso
```

```
3f9c2ab HEAD@{0}: reset: moving to HEAD~1
a71d0e4 HEAD@{1}: commit: Add FIFO overflow flag      ← the "lost" commit
```

```bash
git branch rescue a71d0e4        # or: git reset --hard HEAD@{1}
```

Reflog is local only and expires (default 90 days reachable / 30 days unreachable).

## Recovering things that aren't in the reflog

```bash
git fsck --lost-found            # dangling commits and blobs → .git/lost-found/
git fsck --unreachable --no-reflog | grep commit
git show <sha>
```

A file you `git add`-ed but never committed and then lost with `reset --hard` still exists as a **dangling blob** — `git fsck --lost-found` will find it.

## Recipes

### Committed to `main` instead of a feature branch (not pushed)

```bash
git branch feature/oops          # new branch keeps the commits
git reset --hard origin/main     # move main back
git switch feature/oops
```

### Committed to the wrong feature branch

```bash
git switch right-branch
git cherry-pick <sha>
git switch wrong-branch
git reset --hard HEAD~1
```

### Pushed a commit with a secret

Reverting is **not enough** — the secret is still in history. Rotate the secret immediately, then see [13 · Authentication & security → leaked secrets](13-authentication-and-security.md#leaked-a-secret).

### Undo `git add .` of everything

```bash
git restore --staged .           # or: git reset
```

### Undo a `git pull` that created a mess

```bash
git reset --hard ORIG_HEAD       # ORIG_HEAD = where you were before the merge/rebase
```

### Discard all local changes and match the remote exactly ⚠

```bash
git fetch origin
git reset --hard origin/main
git clean -fdn   # preview
git clean -fd
```

## Next

→ [10 · Tags & releases](10-tags-and-releases.md)
