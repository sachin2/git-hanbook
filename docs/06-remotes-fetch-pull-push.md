# 06 · Remotes: Fetch, Pull, Push

## Managing remotes

```bash
git remote -v                                   # list with URLs
git remote add origin git@github.com:me/repo.git
git remote add upstream https://github.com/original/repo.git   # fork workflow
git remote set-url origin git@github.com:me/new.git             # change URL (e.g. HTTPS→SSH)
git remote rename origin old-origin
git remote remove old-origin
git remote show origin                          # branches, tracking, stale refs
git remote prune origin                         # drop refs to deleted remote branches
```

## Upstream (tracking) branches

A local branch can "track" a remote branch. That gives you bare `git pull`/`git push` and ahead/behind counts.

```bash
git push -u origin feature                      # push + set upstream
git branch -u origin/feature                    # set upstream for current branch
git branch --unset-upstream
git status -sb                                  # ## feature...origin/feature [ahead 2, behind 1]
git rev-list --left-right --count @{u}...HEAD   # "behind ahead" numbers
```

## `git fetch` — always safe

Fetch downloads new commits/refs and updates `origin/*`. It **never** touches your working tree or local branches.

```bash
git fetch                    # default remote
git fetch --all              # all remotes
git fetch --prune            # also delete stale origin/* refs (set fetch.prune=true)
git fetch origin main        # just one branch
git fetch --tags
```

Then look before integrating:

```bash
git log --oneline HEAD..origin/main     # what's new upstream
git diff HEAD...origin/main
```

## `git pull` = fetch + integrate

| Command | Integrates by | Result |
|---|---|---|
| `git pull --ff-only` | fast-forward only | Fails if you have local commits — safest |
| `git pull --rebase` | rebasing your local commits on top | Linear history |
| `git pull --no-rebase` | merge | Creates "Merge branch 'main' of …" commits |

Since Git 2.27 an un-configured `git pull` with divergent branches prints *"You have divergent branches and need to specify how to reconcile them"*. Pick a default once:

```bash
git config --global pull.rebase true       # recommended for feature work
# or
git config --global pull.ff only           # refuse; decide manually each time
```

Rebase-on-pull with local uncommitted changes:

```bash
git config --global rebase.autoStash true   # stash, pull --rebase, unstash automatically
```

## `git push`

```bash
git push                              # current branch → its upstream
git push origin feature               # explicit
git push origin local:remote-name     # push under a different name
git push origin HEAD                  # current branch, same name
git push --tags                       # all tags (prefer pushing one tag)
git push origin v1.2.0
git push --follow-tags                # commits + annotated tags reachable from them
git push origin --delete feature      # delete remote branch
git push --dry-run
```

### Rejected push: *"Updates were rejected because the remote contains work that you do not have locally"*

Someone pushed first. Do **not** force-push. Integrate:

```bash
git pull --rebase       # or git fetch && git rebase origin/main
# resolve conflicts if any
git push
```

### Force-pushing safely

Needed after rebasing/amending a branch that's already on the remote (your own feature branch only).

```bash
git push --force-with-lease                          # refuse if remote moved since your last fetch
git push --force-with-lease --force-if-includes     # (Git ≥ 2.30) also guards against background fetches
```

> **Never `git push --force` to `main`/shared branches.** It silently deletes other people's commits. Protect important branches on the server (branch protection rules).

> **Gotcha:** `--force-with-lease` compares with your *local* `origin/feature`. If an IDE auto-fetches in the background, the lease is "satisfied" even though you never saw the new commits. `--force-if-includes` closes that gap.

Make it the default:

```bash
git config --global alias.pushf "push --force-with-lease --force-if-includes"
```

## Fork workflow: keep your fork in sync

```bash
git remote add upstream https://github.com/original/repo.git
git fetch upstream
git switch main
git rebase upstream/main        # or: git merge --ff-only upstream/main
git push origin main
```

## Multiple push URLs (mirror to two servers)

```bash
git remote set-url --add --push origin git@github.com:me/repo.git
git remote set-url --add --push origin git@gitlab.com:me/repo.git
git push        # pushes to both
```

## Push-related settings worth knowing

| Setting | Effect |
|---|---|
| `push.default simple` | Push current branch to same-named upstream (default) |
| `push.autoSetupRemote true` | First `git push` sets upstream automatically (Git ≥ 2.37) |
| `push.followTags true` | Always push annotated tags along with commits |
| `fetch.prune true` | Remove stale remote-tracking branches on fetch |
| `remote.origin.tagOpt --no-tags` | Never fetch tags from origin |

## Next

→ [07 · Stashing](07-stash.md)
