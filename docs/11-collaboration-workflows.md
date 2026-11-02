# 11 · Collaboration Workflows

## Choosing a branching model

| Model | Shape | Fits |
|---|---|---|
| **Trunk-based** | Everyone merges small, short-lived branches (hours–2 days) into `main`; feature flags hide unfinished work | CI/CD-heavy teams, frequent releases |
| **GitHub Flow** | `main` is always deployable; feature branch → PR → review → merge → deploy | Most teams and projects; the sane default |
| **Git Flow** | `main` (releases) + `develop` + `feature/*`, `release/*`, `hotfix/*` | Versioned products with scheduled releases and maintained old versions |
| **Release branches** | `main` + long-lived `release/x.y` receiving cherry-picked fixes | Firmware, silicon/IP deliveries, anything supported after ship |
| **Fork & PR** | Contributors push to their own fork, open PRs to upstream | Open source, external contributors |

Rule of thumb: start with **GitHub Flow**; add release branches only when you actually maintain old versions.

## Feature branch → pull request lifecycle

```bash
git switch main && git pull --ff-only
git switch -c feat/123-burst-support
# … small, focused commits …
git fetch && git rebase origin/main        # keep current; resolve conflicts early
git push -u origin feat/123-burst-support
# open PR / merge request in the web UI (or: gh pr create --fill)
# address review: more commits, or fixup + autosquash, then push --force-with-lease
# after merge:
git switch main && git pull --ff-only
git branch -d feat/123-burst-support
```

### PR merge options (server side)

| Button | Result |
|---|---|
| Create a merge commit | All commits + merge commit |
| Squash and merge | One commit on `main` — clean, but loses granular history |
| Rebase and merge | Commits replayed linearly on `main` |

Pick **one** per repository and enforce it in settings.

## Fork workflow

```bash
git clone git@github.com:me/project.git
cd project
git remote add upstream https://github.com/org/project.git
git fetch upstream
git switch -c fix/typo upstream/main
# commit…
git push -u origin fix/typo           # to your fork, then open PR to upstream
```

Keep `main` of your fork a pure mirror of upstream; never commit to it directly.

## Commit message conventions

### The seven rules

1. Subject ≤ ~50 characters, body wrapped at 72
2. Imperative mood: "Add", "Fix", not "Added", "Fixes"
3. No trailing period in the subject
4. Blank line between subject and body
5. Body explains **what and why**, not how (the diff shows how)
6. Reference tickets: `Refs: #123`, `Closes #123`
7. One logical change per commit

```
Fix FIFO overflow flag asserting one cycle late

The full flag was derived from the registered write pointer, so a
write in the same cycle as the last free slot was not seen until the
next edge. Compare against the next-state pointer instead.

Closes #87
```

### Conventional Commits (optional, tool-friendly)

```
<type>(<scope>): <subject>

feat(axi): add INCR burst support
fix(fifo): assert full on the correct cycle
docs: describe CDC constraints
refactor, test, chore, ci, build, perf, style
feat!: ...  or  BREAKING CHANGE: ...   → major version bump
```

Enables automatic changelogs and semantic versioning (semantic-release, release-please, git-cliff).

### Trailers

```
Co-authored-by: Name <mail@example.com>
Signed-off-by: Name <mail@example.com>       # git commit -s  (DCO)
Reviewed-by: …
```

## Code review etiquette

- Keep PRs small (< ~400 changed lines). Big PRs get rubber-stamped.
- Describe *why*, how to test, and what to look at closely.
- Separate refactors/formatting from behaviour changes — different commits, ideally different PRs.
- Respond to every comment; resolve threads only when addressed.
- As reviewer: ask questions, distinguish blocking issues from nits ("nit:").

## Server-side protection (configure this!)

- Protect `main` and `release/*`: no force-push, no deletion.
- Require PRs, at least one approval, passing CI.
- Require linear history or signed commits if your team wants them.
- `CODEOWNERS` file to auto-request reviewers per path:
  ```
  /rtl/axi/      @alice
  /constraints/  @bob @carol
  ```

## Working on the same branch as someone else

- Always `git pull --rebase` before pushing.
- **Never** force-push a shared branch; if history must be rewritten, coordinate and have everyone re-sync with `git fetch && git reset --hard origin/branch` (after saving their work).

## Next

→ [12 · Advanced tools](12-advanced-tools.md)
