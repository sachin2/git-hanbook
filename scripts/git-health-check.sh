#!/usr/bin/env bash
# git-health-check.sh — quick report on a repository's state and hygiene.
# Usage: scripts/git-health-check.sh [path-to-repo]
set -uo pipefail

repo="${1:-.}"
cd "$repo" || { echo "No such directory: $repo"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Not a git repository: $repo"; exit 1; }

hr() { printf '\n== %s ==\n' "$1"; }

hr "Repository"
echo "Root:            $(git rev-parse --show-toplevel)"
echo "Git version:     $(git --version | awk '{print $3}')"
echo "Current branch:  $(git branch --show-current || echo '(detached HEAD)')"
upstream=$(git rev-parse --abbrev-ref '@{u}' 2>/dev/null || true)
if [ -n "$upstream" ]; then
  read -r behind ahead < <(git rev-list --left-right --count "$upstream...HEAD")
  echo "Upstream:        $upstream (ahead $ahead, behind $behind)"
else
  echo "Upstream:        (none)"
fi

hr "Working tree"
if [ -z "$(git status --porcelain)" ]; then echo "Clean"; else git status -s | head -20; fi
echo "Stashes:         $(git stash list | wc -l)"

hr "In-progress operations"
gd=$(git rev-parse --git-dir)
found=0
for f in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD BISECT_LOG rebase-merge rebase-apply; do
  if [ -e "$gd/$f" ]; then echo "⚠ $f present"; found=1; fi
done
[ -e "$gd/index.lock" ] && { echo "⚠ index.lock exists (crashed git process?)"; found=1; }
[ "$found" -eq 0 ] && echo "None"

hr "Branches"
echo "Local branches:  $(git branch | wc -l)"
gone=$(git for-each-ref --format '%(refname:short) %(upstream:track)' refs/heads | awk '$2=="[gone]" {print $1}')
if [ -n "$gone" ]; then echo "Upstream deleted (safe to clean?):"; echo "$gone" | sed 's/^/  /'; fi
default=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || echo "")
if [ -n "$default" ]; then
  merged=$(git branch --merged "$default" | grep -vE '^\*|^\s*(main|master|develop)$' || true)
  [ -n "$merged" ] && { echo "Merged into $default:"; echo "$merged" | sed 's/^ */  /'; }
fi

hr "Hygiene"
[ -f .gitignore ]     && echo "✔ .gitignore"     || echo "✖ no .gitignore"
[ -f .gitattributes ] && echo "✔ .gitattributes" || echo "• no .gitattributes (line-ending policy)"
[ -f README.md ] || [ -f README ] && echo "✔ README" || echo "✖ no README"
echo "user.email:      $(git config user.email || echo '✖ not set')"
big=$(git ls-files -z | xargs -0 -r du -k 2>/dev/null | awk '$1 > 5120 {printf "  %6d KB  %s\n", $1, $2}' | sort -rn | head -10)
[ -n "$big" ] && { echo "Tracked files > 5 MB:"; echo "$big"; } || echo "✔ no tracked files > 5 MB"
secrets=$(git ls-files | grep -iE '(^|/)(\.env|id_rsa|id_ed25519|.*\.pem|.*\.key|credentials)$' || true)
[ -n "$secrets" ] && { echo "⚠ Possibly sensitive tracked files:"; echo "$secrets" | sed 's/^/  /'; }

hr "Size"
git count-objects -vH | grep -E 'size-pack|count|size:' | sed 's/^/  /'
