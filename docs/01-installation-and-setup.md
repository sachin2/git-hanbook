# 01 · Installation & First-Time Setup

## Install Git

| Platform | Command / source | Notes |
|---|---|---|
| Debian / Ubuntu | `sudo apt update && sudo apt install git` | For a newer Git: `sudo add-apt-repository ppa:git-core/ppa` first |
| Fedora / RHEL | `sudo dnf install git` | |
| Arch | `sudo pacman -S git` | |
| macOS | `brew install git` | Apple's bundled Git (`xcode-select --install`) lags behind |
| Windows | `winget install --id Git.Git -e` or git-scm.com installer | Includes Git Bash, Git Credential Manager |
| WSL | Install inside the distro (`apt install git`) | Keep repos in the Linux filesystem (`~/…`), **not** `/mnt/c/…` — it is many times faster |

Check the version:

```bash
git --version
```

## Mandatory: who you are

Every commit records an author name and e-mail. Set them once, globally:

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

> **Gotcha:** GitHub/GitLab attribute commits to your account by e-mail. If your commits show up as "unknown user", the e-mail in the commit doesn't match a verified e-mail on your account. Use the provider's `noreply` address if you want to keep your e-mail private (e.g. `12345+user@users.noreply.github.com`).

Use a different identity per directory (work vs. personal) — see [Configuration & aliases → conditional includes](14-configuration-and-aliases.md#conditional-includes).

## Strongly recommended first settings

```bash
# Name new repositories' first branch 'main'
git config --global init.defaultBranch main

# Editor for commit messages / interactive rebase
git config --global core.editor "code --wait"      # VS Code
# git config --global core.editor "vim"
# git config --global core.editor "nano"

# Make `git pull` refuse to create surprise merge commits
git config --global pull.ff only
# …or always rebase on pull instead:
# git config --global pull.rebase true

# Push the current branch to a same-named branch, and set upstream automatically (Git ≥ 2.37)
git config --global push.default simple
git config --global push.autoSetupRemote true

# Prune deleted remote branches on every fetch
git config --global fetch.prune true

# Better diffs
git config --global diff.algorithm histogram
git config --global diff.colorMoved zebra

# Remember conflict resolutions
git config --global rerere.enabled true

# Show 3-way conflict markers (includes the common ancestor)
git config --global merge.conflictStyle zdiff3     # Git ≥ 2.35; use 'diff3' on older Git
```

A complete commented file is in [`examples/gitconfig.recommended`](../examples/gitconfig.recommended).

## Line endings (the classic cross-platform trap)

Windows uses `CRLF`, Linux/macOS use `LF`. Mixed line endings create diffs where "every line changed".

**Best practice — let the repository decide, not each developer's machine.** Commit a `.gitattributes`:

```gitattributes
* text=auto eol=lf
*.bat text eol=crlf
*.cmd text eol=crlf
*.png binary
*.pdf binary
```

Per-machine fallback settings:

```bash
# Windows
git config --global core.autocrlf true
# Linux / macOS
git config --global core.autocrlf input
```

After adding `.gitattributes` to an existing repo, renormalise once:

```bash
git add --renormalize .
git commit -m "Normalize line endings"
```

## Case sensitivity & long paths (Windows/macOS)

```bash
# Windows: allow paths > 260 characters
git config --global core.longpaths true
```

macOS and Windows filesystems are case-*insensitive* by default. Renaming `Readme.md` → `README.md` needs:

```bash
git mv Readme.md README.md        # works on modern Git
# if it doesn't:
git mv Readme.md tmp && git mv tmp README.md
```

## Verify your setup

```bash
git config --list --show-origin     # every setting and the file it came from
git config --global --edit          # open your global config in the editor
```

## Next

→ [02 · Core concepts & mental model](02-core-concepts.md)
