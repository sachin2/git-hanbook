# Glossary

| Term | Meaning |
|---|---|
| **Ancestor** | A commit reachable by following parent links from another commit. |
| **Annotated tag** | A tag object with tagger, date, message and optional signature. |
| **Bare repository** | A repository without a working tree; used on servers. |
| **Blob** | Object storing a file's contents. |
| **Branch** | A movable named pointer to a commit. |
| **Cherry-pick** | Applying the changes of an existing commit as a new commit elsewhere. |
| **Clone** | A full copy of a repository including its history. |
| **Commit** | A snapshot of the project tree plus metadata and parent pointer(s). |
| **Conflict** | Overlapping changes Git can't combine automatically. |
| **Detached HEAD** | HEAD points at a commit directly instead of at a branch. |
| **Fast-forward** | Advancing a branch pointer along a straight line of commits — no merge commit needed. |
| **Fetch** | Download objects/refs from a remote without changing local branches. |
| **Force push** | Overwriting a remote branch with history that doesn't contain the remote's commits. |
| **Fork** | A server-side copy of a repository under another account. |
| **HEAD** | The currently checked-out branch/commit. |
| **Hook** | Script Git runs at certain events (pre-commit, pre-push…). |
| **Hunk** | A contiguous block of changes in a diff. |
| **Index / staging area** | The proposed contents of the next commit. |
| **LFS** | Large File Storage extension: stores big files outside the Git object store. |
| **Merge** | Combining histories; may create a commit with two parents. |
| **Merge base** | Best common ancestor of two commits. |
| **Origin** | Default name for the remote you cloned from. |
| **ORIG_HEAD** | Where HEAD was before the last reset/merge/rebase. |
| **Pull** | Fetch plus merge/rebase into the current branch. |
| **Pull request / merge request** | Server feature to propose, review and merge a branch. |
| **Push** | Upload local commits to a remote branch. |
| **Rebase** | Re-applying commits on top of another base, creating new commits. |
| **Ref** | Any named pointer: branch, tag, remote-tracking branch, HEAD. |
| **Reflog** | Local log of where HEAD and branches have pointed. |
| **Remote** | A named URL of another copy of the repository. |
| **Remote-tracking branch** | Local read-only ref (e.g. `origin/main`) recording a remote branch's last known position. |
| **rerere** | "Reuse recorded resolution" of conflicts. |
| **Revert** | A new commit that undoes an earlier commit. |
| **SHA / hash** | The content-derived identifier of an object. |
| **Shallow clone** | Clone with truncated history (`--depth`). |
| **Sparse checkout** | Only part of the tree is present in the working directory. |
| **Squash** | Combining several commits into one. |
| **Stash** | Temporary storage for uncommitted changes. |
| **Submodule** | A repository embedded in another at a pinned commit. |
| **Subtree** | Another repository's content merged into a subdirectory. |
| **Tree** | Object representing a directory listing. |
| **Upstream** | The remote branch a local branch tracks; also the original repo of a fork. |
| **Working tree** | The checked-out files on disk. |
| **Worktree** | An additional working tree attached to the same repository. |
