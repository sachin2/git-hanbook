# 14 · Configuration & Aliases

## Config levels (later overrides earlier)

| Level | File | Flag |
|---|---|---|
| System | `/etc/gitconfig` | `--system` |
| Global (user) | `~/.gitconfig` or `~/.config/git/config` | `--global` |
| Local (repo) | `.git/config` | `--local` (default) |
| Worktree | `.git/config.worktree` | `--worktree` |
| Command line | `git -c key=value …` | one-off |

```bash
git config --list --show-origin --show-scope    # see everything and where it comes from
git config --get pull.rebase
git config --global --unset core.editor
git config --global --edit
```

## Conditional includes

Different identity (or settings) per directory:

```ini
# ~/.gitconfig
[user]
    name = Your Name
    email = you@personal.example
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work
[includeIf "hasconfig:remote.*.url:git@gitlab.company.com:*/**"]
    path = ~/.gitconfig-work
```

```ini
# ~/.gitconfig-work
[user]
    email = you@company.example
    signingkey = ~/.ssh/id_ed25519_work.pub
```

> **Gotcha:** `gitdir:` paths need a trailing `/` to match subdirectories. Use `gitdir/i:` for case-insensitive matching on Windows/macOS.

## Recommended settings (explained)

| Setting | Why |
|---|---|
| `init.defaultBranch main` | Consistent default branch |
| `pull.rebase true` *or* `pull.ff only` | No accidental merge commits from pull |
| `push.autoSetupRemote true` | No more `--set-upstream` errors |
| `push.followTags true` | Annotated tags travel with commits |
| `fetch.prune true` / `fetch.pruneTags true` | Remove stale remote refs |
| `rebase.autoStash true` | Rebase with a dirty tree |
| `rebase.autoSquash true` | `--fixup` commits sorted automatically |
| `rebase.updateRefs true` | Stacked branches move together |
| `rerere.enabled true` | Reuse conflict resolutions |
| `merge.conflictStyle zdiff3` | See the base version in conflicts |
| `diff.algorithm histogram` | More readable diffs |
| `diff.colorMoved zebra` | Moved code shown differently from added/removed |
| `branch.sort -committerdate` | Recent branches first |
| `tag.sort version:refname` | `v1.10` after `v1.9` |
| `commit.verbose true` | Diff visible while writing message |
| `help.autocorrect prompt` | "Did you mean…?" with confirmation |
| `core.fsmonitor true` | Faster `status` in huge repos (Git ≥ 2.37 on Win/macOS) |
| `core.untrackedCache true` | Faster `status` |

Everything is collected in [`examples/gitconfig.recommended`](../examples/gitconfig.recommended).

## Aliases

```bash
git config --global alias.st "status -sb"
git config --global alias.co switch
git config --global alias.lg "log --graph --oneline --decorate --all"
```

Useful set (add to `~/.gitconfig`):

```ini
[alias]
    st      = status -sb
    sw      = switch
    br      = branch -vv --sort=-committerdate
    lg      = log --graph --pretty=format:'%C(yellow)%h%C(reset) %C(blue)%ad%C(reset) %s%C(auto)%d%C(reset) %C(dim)[%an]' --date=short
    lga     = !git lg --all
    last    = log -1 HEAD --stat
    unstage = restore --staged
    amend   = commit --amend --no-edit
    fixup   = commit --fixup
    pushf   = push --force-with-lease --force-if-includes
    up      = pull --rebase --autostash
    undo    = reset --soft HEAD~1
    wip     = !git add -A && git commit -m 'WIP' --no-verify
    unwip   = !git log -1 --format=%s | grep -q '^WIP$' && git reset HEAD~1
    ahead   = log --oneline @{u}..
    behind  = log --oneline ..@{u}
    gone    = !git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' refs/heads | awk '$2==\"[gone]\" {print $1}'
    prune-gone = !git gone | xargs -r git branch -D
    aliases = config --get-regexp ^alias\\.
    root    = rev-parse --show-toplevel
```

Aliases starting with `!` run as shell commands from the repository root.

## Environment variables worth knowing

| Variable | Use |
|---|---|
| `GIT_TRACE=1` | Trace what Git executes |
| `GIT_TRACE_CURL=1` | Debug HTTP(S) transport |
| `GIT_SSH_COMMAND="ssh -v"` | Debug SSH transport |
| `GIT_EDITOR`, `GIT_PAGER` | Override editor/pager |
| `GIT_DIR`, `GIT_WORK_TREE` | Operate on a repo from elsewhere |
| `GIT_LFS_SKIP_SMUDGE=1` | Clone without downloading LFS files |

## Pager / diff tools

```bash
git config --global core.pager "delta"          # syntax-highlighted diffs (install git-delta)
git config --global diff.tool meld
git config --global merge.tool meld
git config --global mergetool.keepBackup false  # no *.orig files
git difftool main -- rtl/top.v
```

## Next

→ [15 · Troubleshooting & gotchas](15-troubleshooting-and-gotchas.md)
