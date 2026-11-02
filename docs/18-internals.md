# 18 · Internals & Plumbing

Understanding what's inside `.git/` makes every porcelain command predictable.

## The `.git` directory

```
.git/
├── HEAD              # "ref: refs/heads/main" (or a raw SHA when detached)
├── config            # repo-local config
├── index             # the staging area (binary)
├── objects/          # all content: loose objects + packs/
├── refs/
│   ├── heads/        # local branches
│   ├── remotes/      # remote-tracking branches
│   └── tags/
├── packed-refs       # refs packed into one file
├── logs/             # reflogs
├── hooks/            # sample hooks
├── info/exclude      # local, uncommitted ignore rules
├── ORIG_HEAD         # previous HEAD before reset/merge/rebase
├── FETCH_HEAD        # what the last fetch retrieved
└── MERGE_HEAD, REBASE_HEAD, CHERRY_PICK_HEAD …  # during operations
```

## Objects by hand

```bash
echo "hello" | git hash-object --stdin        # compute blob ID
git cat-file -t <sha>                         # type: blob/tree/commit/tag
git cat-file -p <sha>                         # pretty-print content
git cat-file -p HEAD                          # commit: tree, parent, author, message
git cat-file -p HEAD^{tree}                   # tree listing
git ls-tree -r HEAD --name-only               # all tracked files in HEAD
git ls-files -s                               # the index: mode, blob SHA, stage, path
git rev-parse HEAD                            # resolve any revision to a SHA
git rev-parse --abbrev-ref HEAD               # current branch name
git rev-list --count HEAD                     # number of commits
```

Building a commit with plumbing only:

```bash
blob=$(echo "content" | git hash-object -w --stdin)
git update-index --add --cacheinfo 100644,$blob,file.txt
tree=$(git write-tree)
commit=$(echo "msg" | git commit-tree $tree -p HEAD)
git update-ref refs/heads/main $commit
```

## Refs

```bash
git show-ref                         # all refs
git for-each-ref --sort=-committerdate refs/heads --format='%(refname:short) %(committerdate:relative)'
git symbolic-ref HEAD                # which branch HEAD points to
git update-ref refs/heads/x <sha>    # move a branch without checkout
```

## Packfiles and storage

New objects are stored loose (zlib-compressed). `git gc` packs them into `objects/pack/*.pack` with delta compression.

```bash
git count-objects -vH                        # size of loose + packed objects
git gc                                       # pack, prune old unreachable objects
git gc --aggressive --prune=now              # rarely needed; slow
git maintenance run --task=gc
git verify-pack -v .git/objects/pack/*.idx | sort -k3 -n | tail -10   # biggest objects
```

Find which files are bloating the repo:

```bash
git rev-list --objects --all \
 | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
 | awk '$1=="blob"' | sort -k3 -n | tail -20
```

## Integrity

```bash
git fsck --full                  # check object graph
git fsck --lost-found            # write dangling objects to .git/lost-found
```

## SHA-1 vs SHA-256

Git can create SHA-256 repositories (`git init --object-format=sha256`). Hosting support is still limited; most repos remain SHA-1 with collision-detection hardening.

## Merge internals (brief)

- Default strategy `ort` (since Git 2.34; replaced `recursive`) — 3-way merge using the merge base.
- `octopus` for merging > 2 branches without conflicts.
- `ours` strategy: keep our tree entirely, record the merge.

## Useful plumbing for scripts

| Need | Command |
|---|---|
| Is the tree dirty? | `git diff --quiet && git diff --cached --quiet` (exit code) |
| Current branch | `git branch --show-current` |
| Repo root | `git rev-parse --show-toplevel` |
| Upstream of branch | `git rev-parse --abbrev-ref @{u}` |
| Machine-readable status | `git status --porcelain=v2 --branch` |
| Is commit X an ancestor of Y? | `git merge-base --is-ancestor X Y` |

Always use plumbing (stable output) rather than parsing porcelain output in scripts.

## Back to start

→ [README](../README.md)
