# Contributing

1. **Only add commands you have actually run.** Note the minimum Git version if it is newer than 2.30.
2. Mark destructive commands with ⚠ and show the safe/preview variant first (`clean -n`, `--dry-run`, `--force-with-lease`).
3. One topic per page in `docs/`; keep the `NN-topic.md` numbering.
4. **When you add or rename a page, update both the table in `README.md` and the `pages` list in `.devin/wiki.json`** — DeepWiki only generates listed pages.
5. Gotchas follow the pattern: *what you see → why → fix*.
6. Commit messages follow [docs/11 → Commit message conventions](docs/11-collaboration-workflows.md#commit-message-conventions).

Local checks before pushing:

```bash
python3 -m json.tool .devin/wiki.json >/dev/null && echo "wiki.json OK"
bash -n scripts/*.sh examples/hooks/*
```
