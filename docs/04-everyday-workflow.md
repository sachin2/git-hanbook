# 04 · Everyday Workflow

The daily loop:

```bash
git switch main && git pull           # 1. start from an up-to-date base
git switch -c feature/xyz             # 2. branch
# … edit …
git status                            # 3. look
git diff                              # 4. review your changes
git add -p                            # 5. stage deliberately
git commit                            # 6. commit with a real message
git push                              # 7. share (push.autoSetupRemote handles -u)
```

## `git status`

```bash
git status            # full
git status -sb        # short + branch/ahead-behind info
```

Short-format codes: `M` modified, `A` added, `D` deleted, `R` renamed, `??` untracked, `UU` conflict. Left column = staged, right column = working tree.

## Staging: `git add`

```bash
git add file.c                 # one file
git add src/                   # a directory
git add -A                     # everything: new, modified, deleted (whole repo)
git add .                      # everything under the current directory
git add -u                     # only already-tracked files (no new files)
git add -p                     # interactively choose hunks  ★ best practice
git add -N newfile.c           # "intent to add": makes new file show in git diff
```

`git add -p` keys: `y` stage hunk, `n` skip, `s` split into smaller hunks, `e` edit the hunk by hand, `q` quit, `?` help.

## Committing

```bash
git commit                     # opens editor — write subject + body
git commit -m "Subject" -m "Body paragraph"
git commit -a -m "msg"         # stage tracked modified files + commit (skips new files!)
git commit --amend             # change the last commit (message and/or content)
git commit --amend --no-edit   # add staged changes to last commit, keep message
git commit --fixup=<sha>       # mark as fix for an earlier commit (see autosquash)
git commit --allow-empty -m "Trigger CI"
git commit -v                  # show the diff in the editor while writing
```

> **Rule:** only `--amend` commits you haven't pushed (or that nobody else has pulled).

Commit message format → [16 · Best practices](16-best-practices.md#commit-messages).

## Seeing what changed: `git diff`

```bash
git diff                       # working tree vs index (unstaged)
git diff --staged              # index vs HEAD (what will be committed)
git diff HEAD                  # working tree vs HEAD (everything)
git diff main..feature         # between two branches' tips
git diff main...feature        # what feature changed since it branched off main  ★ PR view
git diff --stat                # summary only
git diff --name-only HEAD~3
git diff --word-diff           # inline word-level changes (great for prose/docs)
git diff -w                    # ignore whitespace
git diff HEAD~1 -- path/file   # limit to a path
```

## History: `git log`

```bash
git log --oneline --graph --decorate --all     # the classic overview  (alias: git lg)
git log -p path/file                           # history with patches for a file
git log --follow -- path/file                  # follow renames
git log --author="Name" --since="2 weeks ago"
git log --grep="timing"                        # search messages
git log -S"clk_div"                            # pickaxe: commits that added/removed this string
git log -G"regex"                              # commits whose diff matches a regex
git log -L 40,60:src/top.v                     # history of specific lines
git log -L :function_name:src/file.c           # history of a function
git log --first-parent main                    # only mainline (merge commits)
git shortlog -sn                               # commits per author
```

## Inspecting single commits & files

```bash
git show <sha>                     # commit + diff
git show <sha> --stat
git show <sha>:path/file           # file content at that commit
git blame path/file                # who last changed each line
git blame -w -C -C -C path/file    # ignore whitespace, detect moved/copied code
git blame -L 100,140 path/file
```

Ignore bulk-format commits in blame:

```bash
echo "<sha-of-reformat-commit>" >> .git-blame-ignore-revs
git config blame.ignoreRevsFile .git-blame-ignore-revs
```

## Moving, renaming, deleting

```bash
git mv old.c new.c                  # rename (Git detects renames anyway, this just stages it)
git rm file.c                       # delete from disk and index
git rm --cached secret.env          # untrack but keep the file on disk
git clean -n                        # preview: what untracked files would be deleted
git clean -fd                       # delete untracked files and dirs   ⚠ irreversible
git clean -fdx                      # …including ignored files (full reset of build outputs) ⚠
git clean -i                        # interactive
```

> **Gotcha:** `git clean` deletes files Git never saw — they are **not** in the reflog. Always run `-n` first.

## Searching the codebase

```bash
git grep "pattern"                  # fast, only tracked files
git grep -n "TODO" -- '*.v' '*.sv'
git grep "pattern" v1.2.0           # search an old version
```

## Next

→ [05 · Branching & merging](05-branching-and-merging.md)
