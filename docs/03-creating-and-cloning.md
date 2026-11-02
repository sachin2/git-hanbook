# 03 · Creating & Cloning Repositories

## Start a new repository

```bash
mkdir my-project && cd my-project
git init                         # creates .git/, branch = init.defaultBranch
git init -b main                 # explicit initial branch name

# write .gitignore FIRST, then:
git add .
git commit -m "Initial commit"
```

Connect it to an (empty) remote and push:

```bash
git remote add origin git@github.com:you/my-project.git
git push -u origin main          # -u = remember origin/main as upstream
```

> **Gotcha:** If you created the remote repo *with* a README/license, your first push is rejected (unrelated histories). Either create the remote empty, or:
> ```bash
> git pull origin main --allow-unrelated-histories
> git push -u origin main
> ```

## Clone an existing repository

```bash
git clone https://github.com/owner/repo.git            # HTTPS
git clone git@github.com:owner/repo.git                # SSH
git clone <url> my-folder                              # custom folder name
git clone --branch develop <url>                       # check out a specific branch
git clone --recurse-submodules <url>                   # include submodules
```

### Cloning large repositories faster

| Need | Command | Trade-off |
|---|---|---|
| Only latest snapshot (CI, quick look) | `git clone --depth 1 <url>` | Shallow: no history, some ops limited |
| Only one branch | `git clone --single-branch --branch main <url>` | Other branches not fetched |
| Full history, blobs on demand | `git clone --filter=blob:none <url>` | **Best default for big repos** — history works, file contents fetched lazily |
| No trees until needed | `git clone --filter=tree:0 <url>` | Fastest, but history commands get slow |
| Only some directories | `git clone --filter=blob:none --sparse <url>` then `git sparse-checkout set dir1 dir2` | See [12 · Advanced](12-advanced-tools.md#sparse-checkout--only-some-directories-on-disk) |
| Exact server copy (backup/migration) | `git clone --mirror <url>` | Bare repo with all refs |

Convert a shallow clone into a full one later:

```bash
git fetch --unshallow
# a shallow single-branch clone also needs:
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch origin
```

## Bare repositories

A **bare** repo has no working tree — it is what lives on a server.

```bash
git init --bare /srv/git/project.git
git clone user@server:/srv/git/project.git     # clone it over SSH
```

Useful for a private remote on a NAS, lab server or USB stick.

## Migrate a repository to a new host (all branches & tags)

```bash
git clone --mirror git@old-host:team/repo.git
cd repo.git
git remote set-url origin git@new-host:team/repo.git
git push --mirror
```

> **Gotcha:** `--mirror` pushes *every* ref, including pull-request refs some hosts expose (`refs/pull/*`). If the push is rejected for those, push explicitly: `git push origin 'refs/heads/*' 'refs/tags/*'`.

## `.gitignore` essentials

```gitignore
# a directory named build, anywhere
build/
# only at the repo root
/out/
# any .log file …
*.log
# … except this one
!keep.log
# tmp/ at any depth
**/tmp/
# pdfs directly in docs/ (not in subfolders)
docs/*.pdf
```

Rules that trip people up:

- **Comments must be on their own line.** `build/  # output` is *not* a comment — the `# output` becomes part of the pattern and nothing matches.

- **`.gitignore` does not affect files that are already tracked.** Stop tracking first:
  ```bash
  git rm -r --cached build/
  git commit -m "Stop tracking build output"
  ```
- You can't re-include a file if its *parent directory* is ignored. Use `dir/*` + `!dir/keep.txt`, not `dir/` + `!dir/keep.txt`.
- Debug which rule matched: `git check-ignore -v path/to/file`.
- Personal ignores (editor junk) go in a **global** ignore file, not the project's:
  ```bash
  git config --global core.excludesFile ~/.gitignore_global
  ```
- Repo-local ignores that must not be committed: `.git/info/exclude`.
- Keep an empty directory: Git doesn't track directories — add a `.gitkeep` file.

Templates: [`examples/gitignore/`](../examples/gitignore/) and the community collection at github.com/github/gitignore.

## Next

→ [04 · Everyday workflow](04-everyday-workflow.md)
