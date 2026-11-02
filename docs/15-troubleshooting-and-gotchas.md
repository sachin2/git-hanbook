# 15 · Troubleshooting & Gotchas

Each entry: **the message you see → why → the fix.**

## Push / pull errors

### `! [rejected] main -> main (fetch first)` / `(non-fast-forward)`
Remote has commits you don't. → `git pull --rebase` (or `git fetch && git rebase origin/main`), resolve, `git push`. **Don't** force-push a shared branch.

### `fatal: The current branch feature has no upstream branch`
→ `git push -u origin feature`. Permanently: `git config --global push.autoSetupRemote true`.

### `hint: You have divergent branches and need to specify how to reconcile them`
Local and remote both have new commits and `pull` has no strategy configured. → `git pull --rebase` once, and set `git config --global pull.rebase true` (or `pull.ff only`).

### `fatal: refusing to merge unrelated histories`
Two repos with no common commit (e.g. remote created with a README). → `git pull origin main --allow-unrelated-histories`.

### `error: failed to push some refs … (stale info)`
Your `--force-with-lease` noticed the remote moved. → `git fetch`, look at what changed, rebase onto it, push again.

### `remote: Permission to X denied` / `403` / `Authentication failed`
Wrong account or expired token. → Check `git remote -v`, re-authenticate (`gh auth login` or clear credential: see [13](13-authentication-and-security.md#https-credential-helpers)), confirm you have write access, check `ssh -T git@github.com` to see which account SSH uses.

### `Permission denied (publickey)`
SSH key not loaded / not uploaded / wrong key. → `ssh-add -l`, `ssh -vT git@github.com`, check `~/.ssh/config`, upload `~/.ssh/id_ed25519.pub`.

### `remote: error: File X is 123 MB; this exceeds GitHub's file size limit of 100 MB`
The big file is in a commit — deleting it in a new commit does **not** help. → If it's in the last commit: `git rm --cached X && git commit --amend`. If deeper: `git filter-repo --path X --invert-paths` or `git lfs migrate import --include="X"`. Then push.

### `RPC failed; curl 56 … / early EOF / the remote end hung up unexpectedly`
Network drop during a large transfer. → Retry; clone with `--filter=blob:none` or `--depth 1` then deepen; check proxy; for pushes, push in smaller chunks (`git push origin <older-sha>:refs/heads/main` then the rest). Increasing `http.postBuffer` only helps with some old servers.

### `SSL certificate problem: unable to get local issuer certificate`
Corporate TLS proxy or missing CA bundle. → `git config --global http.sslCAInfo /path/ca.pem` (or `http.sslBackend schannel` on Windows). **Never** use `http.sslVerify false` globally.

## Local state errors

### `error: Your local changes to the following files would be overwritten by checkout/merge`
→ Commit, `git stash`, or discard (`git restore <file>`), then retry. Or `git switch --merge`.

### `error: The following untracked working tree files would be overwritten`
An untracked local file has the same path as a tracked file on the target branch. → Move/delete it (`git clean -n` to preview), or `git stash -u`.

### `You are in 'detached HEAD' state`
You checked out a commit/tag, not a branch. Fine for looking. To keep new work: `git switch -c new-branch`. Lost commits from a detached HEAD → `git reflog`.

### `fatal: Unable to create '.git/index.lock': File exists`
Another Git process is running, or one crashed. → Make sure no Git/IDE process is active, then `rm .git/index.lock`.

### `fatal: not a git repository (or any of the parent directories)`
Wrong directory, or `.git` missing. → `cd` into the repo; `git rev-parse --show-toplevel`.

### `fatal: detected dubious ownership in repository`
Repo owned by another user (shared drives, WSL, Docker volumes). → If trusted: `git config --global --add safe.directory /path/to/repo`.

### `warning: LF will be replaced by CRLF`
Line-ending normalisation. → Add `.gitattributes` (`* text=auto eol=lf`) — see [01](01-installation-and-setup.md#line-endings-the-classic-cross-platform-trap).

### "Every line of the file changed" in the diff
Line endings or file mode (chmod) changed. → `git diff -w`/`--ignore-cr-at-eol` to confirm; for permission noise: `git config core.fileMode false` (common on Windows/WSL/FAT drives).

### `.gitignore` not working
File already tracked. → `git rm --cached <file>` and commit. Debug: `git check-ignore -v <file>`.

### Conflict markers committed by accident
→ `git grep -n '^<<<<<<< \|^>>>>>>> '`. Prevent with a pre-commit hook ([`examples/hooks/pre-commit`](../examples/hooks/pre-commit)) or `git diff --check`.

### `CONFLICT (modify/delete)`
One side edited a file, the other deleted it. → Keep: `git add file`. Delete: `git rm file`. Then continue.

### Rebase stopped and I don't know where I am
→ `git status` explains it. `git rebase --abort` returns to the starting point. `git rebase --continue` after resolving.

### `fatal: bad object` / `error: object file … is empty`
Corruption (power loss, full disk, cloud-sync folder). → `git fsck --full`. If you have a remote, the easiest fix: fresh clone, copy over your uncommitted files. **Keep Git repos out of Dropbox/OneDrive/Google-Drive sync folders.**

## Submodule gotchas

- Empty submodule directories after clone → `git submodule update --init --recursive`.
- `fatal: reference is not a tree` → the parent points to a submodule commit that was never pushed. Push the submodule.
- Changes inside a submodule lost after `submodule update` → you committed on a detached HEAD; recover via the submodule's reflog.

## Surprising behaviours

| Surprise | Explanation |
|---|---|
| `git commit -a` didn't include my new file | `-a` only stages files Git already tracks |
| Empty directories aren't committed | Git tracks files, not directories — add `.gitkeep` |
| `git pull` created "Merge branch 'main' of…" | `pull` merged; configure `pull.rebase` |
| `git branch -d` says not fully merged after a squash-merge PR | Squash creates new commits; use `-D` |
| `ours`/`theirs` reversed during rebase | Rebase replays *your* commits onto *theirs* — see [05](05-branching-and-merging.md) |
| Deleted remote branches still appear in `git branch -a` | Run `git fetch --prune` |
| Renamed file shows as delete + add | Rename detection happens at diff time; both are fine. `git log --follow` to trace |
| Tags didn't get pushed | `push` doesn't push tags by default |
| Case-only rename didn't happen (macOS/Windows) | `git mv` via a temp name |
| Changed `.gitattributes`, nothing happened | `git add --renormalize .` |
| `HEAD~` vs `HEAD^` | Same for normal commits; differ on merges (`^2` = 2nd parent, `~2` = grandparent) |

## Diagnose anything

```bash
git status
git log --oneline --graph --all -20
git reflog -20
git remote -v && git branch -vv
GIT_TRACE=1 git <command>
git config --list --show-origin
```

## Next

→ [16 · Best practices](16-best-practices.md)
