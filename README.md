# The Git Handbook

A practical, opinionated, copy-paste-friendly knowledge base for working with **Git** — from first clone to rewriting history, from daily push/pull to rescuing a repository that looks broken.

This repository is structured to be indexed by [**DeepWiki**](https://deepwiki.com/) (see [`.devin/wiki.json`](.devin/wiki.json)), but every page is plain Markdown and reads perfectly well on GitHub or locally.

\---

## How the handbook is organised

|#|Page|What you get|
|-|-|-|
|01|[Installation \& first-time setup](docs/01-installation-and-setup.md)|Install on Linux/macOS/Windows, identity, editor, line endings, default branch|
|02|[Core concepts \& mental model](docs/02-core-concepts.md)|Working tree / index / repository, objects, refs, HEAD, the three trees|
|03|[Creating \& cloning repositories](docs/03-creating-and-cloning.md)|`init`, `clone` (shallow, partial, sparse, mirror), `.gitignore`|
|04|[Everyday workflow](docs/04-everyday-workflow.md)|`status`, `add`, `commit`, `diff`, `log`, `show`, `blame`, `mv`, `rm`|
|05|[Branching \& merging](docs/05-branching-and-merging.md)|Create/switch/delete branches, merge strategies, conflict resolution|
|06|[Remotes: fetch, pull, push](docs/06-remotes-fetch-pull-push.md)|Remotes, tracking branches, pull strategies, safe force-push|
|07|[Stashing](docs/07-stash.md)|Every `stash` variant, partial stash, recovering dropped stashes|
|08|[Rebase \& rewriting history](docs/08-rebase-and-history-rewriting.md)|Rebase, interactive rebase, fixup/autosquash, `--onto`, `filter-repo`|
|09|[Undoing things](docs/09-undoing-changes.md)|`restore`, `reset`, `revert`, `reflog` — a decision table for every "oops"|
|10|[Tags \& releases](docs/10-tags-and-releases.md)|Lightweight vs annotated, signed tags, pushing/deleting tags, `describe`|
|11|[Collaboration workflows](docs/11-collaboration-workflows.md)|Trunk-based, GitHub Flow, Git Flow, fork \& PR, commit-message conventions|
|12|[Advanced tools](docs/12-advanced-tools.md)|`cherry-pick`, `bisect`, `worktree`, submodules, subtrees, sparse-checkout, `rerere`, hooks, LFS|
|13|[Authentication \& security](docs/13-authentication-and-security.md)|SSH keys, HTTPS tokens, credential helpers, commit signing, leaked secrets|
|14|[Configuration \& aliases](docs/14-configuration-and-aliases.md)|Config levels, conditional includes, recommended settings, aliases|
|15|[Troubleshooting \& gotchas](docs/15-troubleshooting-and-gotchas.md)|The error messages you will actually see and how to fix each one|
|16|[Best practices](docs/16-best-practices.md)|Commit hygiene, branching discipline, repo hygiene, review etiquette|
|17|[Git for hardware / EDA projects](docs/17-git-for-hardware-projects.md)|Vivado, Quartus, Cadence/Virtuoso, open-source EDA, large binaries|
|18|[Internals \& plumbing](docs/18-internals.md)|Objects on disk, packfiles, `cat-file`, `fsck`, `gc`, maintenance|

Quick references:

* [**CHEATSHEET.md**](CHEATSHEET.md) — one-page command reference
* [**GLOSSARY.md**](GLOSSARY.md) — every Git term in one sentence
* [`examples/`](examples/) — ready-to-use `.gitconfig`, `.gitattributes`, `.gitignore` templates and hooks
* [`scripts/`](scripts/) — small helper scripts (branch cleanup, repo health check)

\---

## The 10 rules that prevent 90 % of Git pain

1. **Run `git status` before and after anything non-trivial.** It tells you exactly where you are.
2. **Commit early, commit small.** A commit is a save point you can always get back to; uncommitted work is not.
3. **Never rewrite history that others have pulled** (no `rebase`/`reset`/`commit --amend` on shared branches).
4. **Use `git push --force-with-lease`, never plain `--force`.**
5. **`git fetch` + look, then integrate.** `git pull` is `fetch` + `merge`/`rebase` in one step — know which one yours does.
6. **Before a risky operation, make a backup branch:** `git branch backup/$(date +%s)`.
7. **The reflog is your undo history.** Almost nothing committed is ever truly lost — see [Undoing things](docs/09-undoing-changes.md).
8. **Never commit secrets, build outputs, or large generated binaries.** Write the `.gitignore` *first*.
9. **One logical change per commit, with a message that explains *why*.**
10. **Read the error message.** Git's messages usually contain the exact command you need.

\---

## Using this repository

```bash
git clone https://github.com/<you>/git-handbook.git
cd git-handbook

# install the recommended config (review it first!)
cat examples/gitconfig.recommended
git config --global include.path "$PWD/examples/gitconfig.recommended"

# run the health check against any repo
./scripts/git-health-check.sh /path/to/some/repo
```

## Getting it onto DeepWiki

1. Push this repository to a **public** GitHub repository.
2. Open `https://deepwiki.com/<owner>/<repo>` (or submit the URL on deepwiki.com).
3. DeepWiki reads [`.devin/wiki.json`](.devin/wiki.json) and generates one wiki page per entry listed there.
4. When you add a page to `docs/`, also add it to `pages` in `.devin/wiki.json` — DeepWiki only generates the pages listed.

## 

