# 12 · Advanced Tools

## Cherry-pick — copy specific commits

```bash
git cherry-pick <sha>                 # apply one commit on current branch
git cherry-pick A^..B                 # range A through B (inclusive)
git cherry-pick -x <sha>              # append "(cherry picked from commit …)" ★ for backports
git cherry-pick -n <sha>              # apply without committing
git cherry-pick -m 1 <merge-sha>      # pick a merge commit relative to parent 1
git cherry-pick --continue | --skip | --abort
```

Use for: backporting fixes to `release/*`, rescuing a commit from an abandoned branch. Avoid as a substitute for merging — duplicated commits with different hashes confuse history.

## Bisect — binary-search for the commit that broke something

```bash
git bisect start
git bisect bad                 # current commit is broken
git bisect good v1.2.0         # this one worked
# Git checks out a midpoint; test it, then:
git bisect good    # or: git bisect bad   or: git bisect skip (can't test)
# … repeat ~log2(N) times …
git bisect reset               # back to where you started
```

Automate it — the script exits 0 = good, 1–124 = bad, 125 = skip:

```bash
git bisect start HEAD v1.2.0
git bisect run make sim-regression
git bisect log > bisect.log        # save / replay with git bisect replay
```

Tip: bisect works best with small, always-building commits — another reason for good commit hygiene.

## Worktree — several branches checked out at once

```bash
git worktree add ../proj-hotfix hotfix/1.2.1        # existing branch
git worktree add -b feat/x ../proj-feat-x main      # new branch from main
git worktree list
git worktree remove ../proj-hotfix
git worktree prune
```

Perfect when a long simulation/synthesis is running in one checkout and you need to fix something else. Far better than cloning twice (shared object store) or stashing.

> **Gotcha:** a branch can be checked out in only one worktree at a time.

## Submodules — a repo inside a repo, pinned to a commit

```bash
git submodule add https://github.com/org/ip-lib.git third_party/ip-lib
git commit -m "Add ip-lib submodule"

git clone --recurse-submodules <url>
git submodule update --init --recursive     # after a normal clone / after pull
git submodule update --remote --merge       # advance submodule to its branch tip
git submodule status
git submodule foreach 'git status -s'

git config --global submodule.recurse true  # pull/switch also update submodules
git config --global status.submoduleSummary true
```

Removing a submodule properly:

```bash
git submodule deinit -f third_party/ip-lib
git rm -f third_party/ip-lib
rm -rf .git/modules/third_party/ip-lib
```

Gotchas:

- The parent repo stores only a **commit pointer**. Committing in the submodule without committing the new pointer in the parent → teammates get the old version.
- After `git pull`, submodules are *not* updated unless `submodule.recurse=true` or you run `git submodule update`.
- Submodules check out in **detached HEAD**. `git switch main` inside before committing there.
- Push the submodule *before* pushing the parent, or others get "reference is not a tree". `git push --recurse-submodules=check` guards against this.

## Subtree — vendor another repo's content (no extra clone step)

```bash
git subtree add --prefix=third_party/lib https://github.com/org/lib.git main --squash
git subtree pull --prefix=third_party/lib https://github.com/org/lib.git main --squash
git subtree push --prefix=third_party/lib git@github.com:me/lib.git my-branch
git subtree split --prefix=rtl/axi -b axi-only     # extract a dir's history into a branch
```

| | Submodule | Subtree |
|---|---|---|
| Clone experience | Needs `--recurse-submodules` | Just works |
| Repo size | Small | Includes vendored files |
| Updating upstream | Easy | More awkward |
| Best for | Large or independently developed dependencies | Small, rarely updated vendored code |

## Sparse checkout — only some directories on disk

```bash
git clone --filter=blob:none --sparse <url> && cd repo
git sparse-checkout set rtl/ constraints/     # cone mode (fast, directory-based)
git sparse-checkout add docs/
git sparse-checkout list
git sparse-checkout disable
```

## rerere — reuse recorded resolutions

```bash
git config --global rerere.enabled true
git config --global rerere.autoUpdate true
```

Git remembers how you resolved a conflict and replays it next time the same conflict appears (repeated rebases, test merges). `git rerere forget path` if you recorded a bad one.

## Hooks — automate checks

Client-side hooks live in `.git/hooks/` (not versioned). Share them by committing a directory and pointing Git at it:

```bash
git config core.hooksPath .githooks
chmod +x .githooks/*
```

| Hook | Runs | Typical use |
|---|---|---|
| `pre-commit` | before commit is created | lint, format check, block large files / secrets |
| `commit-msg` | after message written | enforce message format |
| `prepare-commit-msg` | before editor opens | insert ticket ID from branch name |
| `pre-push` | before push | run fast tests, block pushes to `main` |
| `post-checkout` / `post-merge` | after switch / pull | regenerate files, update submodules |

Examples in [`examples/hooks/`](../examples/hooks/). Bypass once with `--no-verify` (use sparingly). The [pre-commit](https://pre-commit.com) framework manages hooks declaratively across a team.

## Git LFS — large binary files

```bash
git lfs install                       # once per machine
git lfs track "*.bit" "*.gds" "*.mp4" # writes .gitattributes
git add .gitattributes
git add design.bit && git commit -m "Add bitstream"
git lfs ls-files
git lfs pull                          # fetch LFS content
git lfs migrate import --include="*.gds" --everything   # move existing history to LFS (rewrites!)
GIT_LFS_SKIP_SMUDGE=1 git clone <url>                    # clone without downloading LFS files
```

Gotchas: LFS needs server support and has storage/bandwidth quotas on hosted services; files committed before `track` stay in normal history until migrated.

## Notes, grep across history, misc

```bash
git notes add -m "Timing closed at 250 MHz" <sha>   # annotate without changing the commit
git log --all --oneline -- '*.xdc'                  # every commit that touched constraints, all branches
git range-diff main@{1} main feature@{1} feature     # compare two versions of a rebased branch
git maintenance start                                # background prefetch/gc/commit-graph
git switch --orphan gh-pages                         # branch with no history (docs sites)
```

## Next

→ [13 · Authentication & security](13-authentication-and-security.md)
