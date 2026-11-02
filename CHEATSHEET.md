# Git Cheatsheet

## Setup
```bash
git config --global user.name "Name"
git config --global user.email "me@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.autoSetupRemote true
```

## Start
```bash
git init                         git clone <url> [dir]
git clone --filter=blob:none <url>     git clone --depth 1 <url>
```

## Look
```bash
git status -sb                   git diff            git diff --staged
git log --oneline --graph --all  git show <rev>      git blame <file>
git log -p -- <file>             git log -S"text"    git reflog
```

## Stage & commit
```bash
git add <file> | -p | -A         git restore --staged <file>
git commit -m "msg"              git commit --amend [--no-edit]
git commit --fixup=<sha>         git rm --cached <file>
```

## Branch
```bash
git branch [-a -vv]              git switch <b>      git switch -c <new>
git switch -                     git branch -m <new> git branch -d|-D <b>
git merge <b> [--no-ff|--ff-only|--squash]           git merge --abort
```

## Remote
```bash
git remote -v                    git remote add <name> <url>
git fetch [--all --prune]        git pull [--rebase|--ff-only]
git push [-u origin <b>]         git push --force-with-lease
git push origin --delete <b>     git push origin <tag>
```

## Stash
```bash
git stash push -m "msg" [-u]     git stash list      git stash show -p
git stash pop [--index]          git stash apply stash@{n}
git stash branch <b>             git stash drop | clear
```

## Rewrite (unpushed / own branches only)
```bash
git rebase origin/main           git rebase -i HEAD~n
git rebase -i --autosquash <base>   git rebase --onto <new> <old> <b>
git rebase --continue | --skip | --abort
```

## Undo
```bash
git restore <file>               # discard edits        ⚠
git reset --soft HEAD~1          # undo commit, keep staged
git reset HEAD~1                 # undo commit, keep unstaged
git reset --hard <rev>           # move & discard       ⚠
git revert <sha>                 # safe undo for pushed commits
git reset --hard ORIG_HEAD       # undo last merge/rebase/reset
git reflog → git branch rescue <sha>
git clean -n → git clean -fd     # untracked files      ⚠
```

## Tags
```bash
git tag -a v1.0 -m "msg"         git push origin v1.0
git tag -d v1.0                  git push origin --delete v1.0
git describe --tags --always --dirty
```

## Advanced
```bash
git cherry-pick -x <sha>         git bisect start/good/bad/run/reset
git worktree add ../dir <b>      git submodule update --init --recursive
git sparse-checkout set <dirs>   git lfs track "*.bin"
git grep "text"                  git range-diff
```

## Revision shorthand
`HEAD~2` grandparent · `HEAD^2` 2nd merge parent · `@{u}` upstream · `HEAD@{3}` reflog · `A..B` in B not A · `A...B` symmetric
