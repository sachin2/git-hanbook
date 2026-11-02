# 02 · Core Concepts & Mental Model

Most Git confusion disappears once you understand **where** your changes live and **what** a branch actually is.

## The three areas

```
 Working tree            Index (staging area)         Repository (.git)
 ─────────────           ────────────────────         ─────────────────
 files you edit   ──add──▶  snapshot of the     ──commit──▶  permanent history
                  ◀─restore─  next commit       ◀──restore --staged / reset──
```

| Area | What it is | Inspect with |
|---|---|---|
| **Working tree** | The files on disk you edit | `git status`, `git diff` |
| **Index / staging area** | The proposed next commit | `git diff --staged` |
| **Repository** | All commits, branches, tags inside `.git/` | `git log`, `git show` |

A file can have three different versions at once — committed, staged, and modified. `git status` shows all of it.

## Snapshots, not diffs

Each commit stores a **complete snapshot** of the project (efficiently — unchanged files are shared), plus:

- a pointer to its **parent** commit(s) (one normally, two for a merge, zero for the first commit)
- author, committer, timestamps
- the message

A commit is identified by its **SHA-1 (or SHA-256) hash** — e.g. `3f9c2ab…`. Change anything in a commit (message, content, parent) and the hash changes. That is why "rewriting history" creates *new* commits rather than editing old ones.

## Objects

| Object | Holds |
|---|---|
| **blob** | File contents (no name) |
| **tree** | A directory listing: names → blobs/trees |
| **commit** | A tree + parents + metadata |
| **tag** (annotated) | A pointer to an object + tagger + message (+ signature) |

Details: [18 · Internals](18-internals.md).

## References: branches, tags, HEAD

- A **branch** is just a movable pointer (a file containing a commit hash) — `.git/refs/heads/main`.
  Creating a branch is instant and costs ~41 bytes.
- A **tag** is a pointer that is not supposed to move.
- **HEAD** says "what you have checked out" — normally it points to a branch (`ref: refs/heads/main`).
  When you commit, the branch HEAD points to moves forward.
- **Detached HEAD**: HEAD points directly to a commit, not a branch. New commits made here belong to no branch and become unreachable when you switch away (recoverable via reflog). Fix: `git switch -c new-branch-name`.
- **Remote-tracking branches** (`origin/main`) are your local, read-only memory of where a branch was on the remote at your last `fetch`.

```
          A───B───C   ◀── main ◀── HEAD
                   \
                    D───E   ◀── feature
                         ▲
                     origin/feature (as of last fetch)
```

## Reachability — why "lost" commits aren't lost

Git keeps any commit reachable from a ref (branch, tag, HEAD, stash, reflog). Unreachable commits are only deleted by garbage collection, and the **reflog keeps them reachable for 90 days** by default (30 days for already-unreachable entries). That's the foundation of almost every recovery technique.

## Revision syntax you'll use daily

| Syntax | Means |
|---|---|
| `HEAD` | Current commit |
| `HEAD~1`, `HEAD~3` | 1st / 3rd ancestor following first parents |
| `HEAD^2` | Second parent of a merge commit |
| `main@{upstream}` / `@{u}` | The branch's upstream (e.g. `origin/main`) |
| `HEAD@{2}` | Where HEAD was two moves ago (reflog) |
| `main@{yesterday}` | Where `main` was yesterday (local reflog) |
| `A..B` | Commits in B but not in A ("what would merging B bring?") |
| `A...B` | Commits in either but not both (symmetric difference) |
| `:/fix typo` | Youngest commit whose message matches "fix typo" |
| `HEAD:path/file` | That file's content in that commit |

```bash
git log main..feature        # commits on feature not yet in main
git log @{u}..               # local commits not yet pushed
git log ..@{u}               # remote commits not yet pulled
git show HEAD~2:src/top.v    # old version of a file
```

## Merge vs. rebase in one picture

```
Merge:   A───B───C───────M      (M has two parents; history preserved)
              \         /
               D───E───

Rebase:  A───B───C───D'───E'    (D,E replayed as new commits; linear history)
```

Detailed trade-offs: [05 · Branching & merging](05-branching-and-merging.md) and [08 · Rebase](08-rebase-and-history-rewriting.md).

## Next

→ [03 · Creating & cloning repositories](03-creating-and-cloning.md)
