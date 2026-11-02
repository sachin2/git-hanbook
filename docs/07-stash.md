# 07 · Stashing

`git stash` shelves uncommitted changes so you get a clean working tree, then lets you re-apply them later — on the same or another branch.

## Core commands

```bash
git stash                          # stash tracked modified + staged changes
git stash push -m "wip: fifo depth"   # with a description  ★ always name them
git stash -u                       # include untracked files
git stash -a                       # include untracked AND ignored files
git stash list                     # stash@{0} is the newest
git stash show -p stash@{1}        # view a stash's diff
git stash apply                    # re-apply newest, keep it in the list
git stash apply stash@{2}
git stash pop                      # re-apply newest and drop it (if no conflict)
git stash drop stash@{1}
git stash clear                    # ⚠ delete all stashes
```

## Partial stashing

```bash
git stash push -p                         # pick hunks interactively
git stash push -- src/fifo.v docs/        # only these paths
git stash push --staged                   # only what's staged (Git ≥ 2.35)
git stash push --keep-index               # stash everything, but leave staged changes in place
```

`--keep-index` is the classic way to **test exactly what you're about to commit**: stage it, `git stash -k -u`, run tests, `git stash pop`.

## Turning a stash into a branch

If the branch has moved on and `pop` would conflict:

```bash
git stash branch fix/fifo stash@{0}
```

This creates a branch at the commit where the stash was made, applies it there (no conflicts by construction), and drops the stash.

## Restoring staged-vs-unstaged state exactly

`apply`/`pop` do **not** restore what was staged — everything comes back unstaged. To restore the index too:

```bash
git stash pop --index
```

## Getting one file out of a stash

```bash
git restore --source=stash@{0} -- path/file
# or
git checkout stash@{0} -- path/file
# untracked files in a stash live in its third parent:
git show stash@{0}^3:path/new-file > path/new-file
```

## Conflicts when popping

`git stash pop` that conflicts **does not drop** the stash. Resolve the files, `git add` them, then:

```bash
git stash drop        # once you're happy
```

## Recovering a dropped or cleared stash

Stashes are commits; dropped ones are dangling until gc.

```bash
git fsck --no-reflog --unreachable | awk '/commit/ {print $3}' \
  | xargs git log --no-walk --oneline --grep="WIP on\|On "
# then
git stash apply <sha>
# or: git branch recovered-stash <sha>
```

## Gotchas & best practices

- **Stashes are local.** They aren't pushed; a stash isn't a backup.
- **Stashes rot.** After a week you won't remember what `stash@{4}` was. Prefer a WIP commit on a branch:
  ```bash
  git switch -c wip/idea && git commit -am "WIP" && git switch -
  ```
- Name every stash (`-m`). `git stash list` becomes readable.
- `git stash` without `-u` leaves **new files** behind — a frequent source of "my file went with me to the other branch".
- `rebase.autoStash` and `merge.autoStash` make Git stash/unstash around rebases and merges automatically.

## Next

→ [08 · Rebase & rewriting history](08-rebase-and-history-rewriting.md)
