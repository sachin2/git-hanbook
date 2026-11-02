# 05 · Branching & Merging

## Branch commands

```bash
git branch                          # list local branches (* = current)
git branch -a                       # include remote-tracking branches
git branch -vv                      # with upstream and ahead/behind
git branch --merged main            # branches fully merged into main (safe to delete)
git branch --no-merged main
git branch --sort=-committerdate    # most recently active first

git switch feature                  # switch to existing branch
git switch -c feature/new           # create + switch
git switch -c fix origin/release    # create from a remote branch
git switch -                        # back to previous branch
git switch --detach v1.2.0          # inspect a tag/commit (detached HEAD)

git branch -m old-name new-name     # rename
git branch -m new-name              # rename current branch
git branch -d feature               # delete (refuses if unmerged)
git branch -D feature               # force delete
git push origin --delete feature    # delete remote branch
```

> `git checkout` still works for all of this, but it is overloaded (branches *and* files). Prefer **`git switch`** for branches and **`git restore`** for files (Git ≥ 2.23).

### Checking out a remote branch someone else pushed

```bash
git fetch
git switch their-branch          # auto-creates a local tracking branch if exactly one remote has it
```

### Switching with uncommitted changes

Git carries changes across if they don't conflict. If they do:

```bash
git stash            # or commit a WIP
git switch other
# or carry them and attempt a merge:
git switch --merge other
```

## Merging

```bash
git switch main
git merge feature                # fast-forward if possible, else merge commit
git merge --no-ff feature        # always create a merge commit (keeps feature grouping)
git merge --ff-only feature      # refuse unless fast-forward
git merge --squash feature       # stage all changes as one; you then commit (no merge link!)
git merge --abort                # back out of a conflicted merge
```

| Type | History | When |
|---|---|---|
| Fast-forward | Linear, no merge commit | Feature is directly ahead of target |
| Merge commit (`--no-ff`) | Preserves branch structure | Long-lived features, release branches |
| Squash | One commit on target, branch history discarded | Messy PR history; small features |
| Rebase + FF | Linear, individual commits kept | Clean, well-structured commits |

> **Gotcha with squash:** the source branch isn't recorded as merged, so `git branch -d` refuses and re-merging it later re-applies changes. Delete squashed branches with `-D`.

## Resolving merge conflicts

```bash
git merge feature
# CONFLICT (content): Merge conflict in src/top.v
git status                       # lists "both modified" files
```

Conflict markers (with `merge.conflictStyle zdiff3`):

```
<<<<<<< HEAD
assign out = a & b;
||||||| base
assign out = a;
=======
assign out = a | c;
>>>>>>> feature
```

Workflow:

1. Edit each file to the correct result; delete all markers.
2. `git add <file>` to mark it resolved.
3. `git commit` (merge) or `git rebase --continue` / `git cherry-pick --continue`.

Handy tools:

```bash
git mergetool                           # opens configured tool (meld, kdiff3, vscode…)
git checkout --ours   path/file         # take our side for the whole file
git checkout --theirs path/file         # take their side
git diff --name-only --diff-filter=U    # list conflicted files
git log --merge -p path/file            # commits on both sides touching the file
git merge -X ours feature               # auto-prefer our side in conflicting hunks only
git merge -X ignore-space-change feature
git grep -n '^<<<<<<< '                 # find leftover markers
```

> **Gotcha — `ours`/`theirs` flip during rebase.** In a *merge*, "ours" = the branch you're on. In a *rebase*, "ours" = the branch you're rebasing **onto** (upstream) and "theirs" = **your** commits being replayed.

> **Gotcha — `-X ours` vs `-s ours`.** `-X ours` resolves *conflicting hunks* in our favour but still merges everything else. `-s ours` discards the other branch's changes entirely while recording a merge. They are not the same.

### Binary / generated file conflicts

Text merging is meaningless for bitstreams, PDFs, netlists. Pick a side:

```bash
git checkout --theirs build/design.bit && git add build/design.bit
```

Better: don't commit generated artefacts. Mark binaries in `.gitattributes` (`*.bit binary`).

## Comparing branches

```bash
git log --oneline main..feature           # what feature has that main doesn't
git log --left-right --oneline main...feature
git diff main...feature                   # changes since the merge base
git merge-base main feature               # the common ancestor commit
git cherry -v main feature                # which feature commits are already upstream (by patch)
```

## Branch naming conventions

```
feature/<ticket>-short-desc     feat/AXI-42-burst-support
fix/<ticket>-short-desc
hotfix/<version>-desc
release/1.4
chore/, docs/, refactor/, test/, experiment/
<user>/<topic>                  for personal scratch branches
```

Lowercase, hyphens, no spaces. Slashes namespace nicely in GUIs — but a branch `feature` and a branch `feature/x` **cannot both exist** (ref `feature` would need to be a file and a directory).

## Next

→ [06 · Remotes: fetch, pull, push](06-remotes-fetch-pull-push.md)
