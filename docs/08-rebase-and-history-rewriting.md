# 08 · Rebase & Rewriting History

> **The golden rule:** never rewrite commits that exist on a branch other people work from. Rewriting your own unpublished (or personal feature) branch is fine and encouraged.

## Plain rebase: move your branch onto a new base

```bash
git switch feature
git fetch
git rebase origin/main
# conflict? fix → git add <file> → git rebase --continue
#            skip this commit   → git rebase --skip
#            give up entirely   → git rebase --abort
git push --force-with-lease
```

```
before:  A──B──C  main          after:  A──B──C──D'──E'  feature
              \                                ▲
               D──E  feature                  main
```

## Interactive rebase: clean up before you share

```bash
git rebase -i HEAD~5            # last 5 commits
git rebase -i origin/main       # everything not yet on main
git rebase -i --root            # all history
```

Editor todo list:

| Command | Effect |
|---|---|
| `pick` | keep as-is |
| `reword` / `r` | keep, edit message |
| `edit` / `e` | stop to amend content (split a commit, etc.) |
| `squash` / `s` | meld into previous, combine messages |
| `fixup` / `f` | meld into previous, discard this message |
| `fixup -C` | meld, use *this* commit's message |
| `drop` / `d` | delete the commit |
| `exec` / `x` | run a shell command (e.g. tests) |
| `break` | stop here |

Reorder lines to reorder commits.

### The fixup + autosquash workflow ★

```bash
git commit --fixup=<sha>            # small fix belonging to an older commit
git rebase -i --autosquash origin/main    # fixups are auto-placed and marked
git config --global rebase.autoSquash true
```

### Splitting one commit into several

```bash
git rebase -i HEAD~3                # mark the commit as 'edit'
git reset HEAD~                     # undo the commit, keep changes unstaged
git add -p && git commit -m "Part 1"
git add -p && git commit -m "Part 2"
git rebase --continue
```

### Run tests on every commit

```bash
git rebase -i --exec "make test" origin/main
```

## `--onto`: transplant a range

```bash
# feature was branched from topic, but should go on main without topic's commits:
git rebase --onto main topic feature

# drop commits C..E (exclusive of C) from the current branch:
git rebase --onto C E
```

## Rebasing branches that depend on each other (stacked branches)

```bash
git rebase --update-refs main        # Git ≥ 2.38: moves intermediate branch pointers too
git config --global rebase.updateRefs true
```

## Preserving merges

```bash
git rebase --rebase-merges origin/main
```

## Rebase vs. merge — which?

| Prefer **rebase** when | Prefer **merge** when |
|---|---|
| Updating your personal feature branch | Integrating a finished feature into `main` (`--no-ff`) |
| You want a linear, bisectable history | The branch is shared / already pulled by others |
| Cleaning up commits before review | You need an exact record of when integration happened |

## Amending the last commit

```bash
git commit --amend                 # message + staged changes
git commit --amend --no-edit
git commit --amend --author="Name <mail>"
git commit --amend --reset-author --no-edit   # after fixing user.email
git commit --amend --date=now --no-edit
```

## Changing author/e-mail across many commits

```bash
git rebase -r origin/main --exec 'git commit --amend --no-edit --reset-author'
```

For whole-repo rewrites use **git-filter-repo** with a mailmap (below). For display-only fixes, add a `.mailmap` file — no rewrite needed:

```
Proper Name <proper@mail.com> <old@mail.com>
```

## Whole-repository rewrites: `git filter-repo`

`git filter-branch` is deprecated (slow, footguns). Install `git-filter-repo` (`pip install git-filter-repo`).

```bash
# Work on a fresh clone!
git clone --no-local repo repo-rewrite && cd repo-rewrite

git filter-repo --path secrets.env --invert-paths          # remove a file from all history
git filter-repo --strip-blobs-bigger-than 50M              # drop huge blobs
git filter-repo --path rtl/ --path tb/                     # keep only these paths
git filter-repo --subdirectory-filter rtl/                 # make rtl/ the new root
git filter-repo --replace-text expressions.txt             # scrub strings (e.g. passwords)
git filter-repo --mailmap my-mailmap                       # rewrite authors
```

Afterwards: every collaborator must **re-clone** (or hard-reset) — old clones still contain the old history and will reintroduce it if they push.

BFG Repo-Cleaner is an alternative for removing big files / passwords.

## Recovering from a rebase gone wrong

```bash
git reflog                          # find "rebase (start)" — the line *before* it is your old tip
git reset --hard HEAD@{5}
# or, while the old tip is still recorded:
git reset --hard ORIG_HEAD
```

## Next

→ [09 · Undoing things](09-undoing-changes.md)
