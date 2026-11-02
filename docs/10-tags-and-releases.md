# 10 · Tags & Releases

## Lightweight vs. annotated

| | Lightweight | Annotated |
|---|---|---|
| What it is | Just a ref to a commit | A full object: tagger, date, message, optional signature |
| Create | `git tag v1.0` | `git tag -a v1.0 -m "Release 1.0"` |
| Use for | Private bookmarks | **Releases** (shown by `describe`, pushed by `--follow-tags`) |

## Commands

```bash
git tag                                  # list
git tag -l "v1.*"                        # filter
git tag --sort=-v:refname                # newest version first
git tag -a v1.2.0 -m "Tapeout candidate" # annotated tag on HEAD
git tag -a v1.1.1 <sha> -m "Hotfix"      # tag an older commit
git tag -s v1.2.0 -m "Signed release"    # GPG/SSH-signed
git tag -v v1.2.0                        # verify signature
git show v1.2.0                          # tag info + commit

git push origin v1.2.0                   # push one tag   ★
git push --follow-tags                   # push commits + their annotated tags
git push origin --tags                   # push ALL tags (incl. stale local junk)

git tag -d v1.2.0                        # delete locally
git push origin --delete v1.2.0          # delete on remote
git push origin :refs/tags/v1.2.0        # same, old syntax
```

> **Gotcha:** `git push` does **not** push tags by default. Set `git config --global push.followTags true`.

> **Gotcha — moving a published tag is a bad idea.** Others' clones keep the old one; `git fetch` won't overwrite an existing local tag unless forced (`git fetch --tags --force`). If you must, delete + recreate + tell everyone. Better: make a new tag (`v1.2.1`).

## Ambiguous names

If a tag and a branch share a name, Git warns `refname 'x' is ambiguous`. Be explicit: `refs/tags/x` or `refs/heads/x` — or just avoid it.

## Checking out a tag

```bash
git switch --detach v1.2.0          # inspect (detached HEAD)
git switch -c hotfix/1.2.1 v1.2.0   # start a branch from it
```

## `git describe` — human-readable build versions

```bash
git describe                  # v1.2.0-14-g3f9c2ab  (14 commits after v1.2.0, at 3f9c2ab)
git describe --tags           # include lightweight tags
git describe --dirty          # append -dirty if working tree has changes
git describe --always --dirty --tags
```

Great for embedding a version/ID in firmware, bitstreams or a USR_ACCESS / ID register at build time:

```bash
GIT_VER=$(git describe --always --dirty --tags)
GIT_SHA=$(git rev-parse --short=8 HEAD)
```

## Semantic versioning

`MAJOR.MINOR.PATCH` — incompatible change / backwards-compatible feature / bug fix. Pre-releases: `v2.0.0-rc.1`. Prefix tags with `v` consistently.

## Release workflow example

```bash
git switch main && git pull --ff-only
git log --oneline $(git describe --tags --abbrev=0)..HEAD    # changes since last tag
git tag -a v1.3.0 -m "v1.3.0: AXI4 burst support, FIFO fixes"
git push origin v1.3.0
```

Changelog since last release:

```bash
git log --pretty='- %s (%h)' --no-merges v1.2.0..v1.3.0
git shortlog --no-merges v1.2.0..v1.3.0
```

## Archives

```bash
git archive --format=tar.gz --prefix=proj-1.3.0/ -o proj-1.3.0.tar.gz v1.3.0
git archive --format=zip -o rtl.zip HEAD rtl/
```

Exclude paths from archives with `.gitattributes`: `tests/ export-ignore`.

## Next

→ [11 · Collaboration workflows](11-collaboration-workflows.md)
