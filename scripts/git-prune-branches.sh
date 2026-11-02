#!/usr/bin/env bash
# git-prune-branches.sh — delete local branches whose remote branch is gone
# or which are fully merged into the default branch.
# Usage: scripts/git-prune-branches.sh [--dry-run]   (dry-run is the default)
#        scripts/git-prune-branches.sh --apply
set -euo pipefail

mode="${1:---dry-run}"
if git remote | grep -qx origin; then git fetch --prune --quiet origin; fi

default=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
if [ -z "$default" ]; then
  for b in origin/main origin/master main master; do
    if git rev-parse --verify --quiet "$b" >/dev/null; then default=$b; break; fi
  done
fi
[ -n "$default" ] || { echo "Could not determine the default branch."; exit 1; }
current=$(git branch --show-current)

mapfile -t gone < <(git for-each-ref --format '%(refname:short) %(upstream:track)' refs/heads \
                    | awk '$2=="[gone]" {print $1}')
mapfile -t merged < <(git branch --format '%(refname:short)' --merged "$default" \
                      | grep -vE '^(main|master|develop|release/.*)$' || true)

candidates=$(printf '%s\n' "${gone[@]}" "${merged[@]}" | grep -v "^${current}\$" | sort -u | sed '/^$/d')

if [ -z "$candidates" ]; then echo "Nothing to prune."; exit 0; fi

echo "Branches to delete (gone upstream or merged into $default):"
echo "$candidates" | sed 's/^/  /'

if [ "$mode" = "--apply" ]; then
  # -D needed for squash-merged branches whose upstream is gone
  echo "$candidates" | xargs git branch -D
else
  echo
  echo "Dry run. Re-run with --apply to delete. (Recover any branch later via 'git reflog'.)"
fi
