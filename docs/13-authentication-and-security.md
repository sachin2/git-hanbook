# 13 · Authentication & Security

## HTTPS vs. SSH

| | HTTPS + token | SSH key |
|---|---|---|
| URL | `https://github.com/owner/repo.git` | `git@github.com:owner/repo.git` |
| Credential | Personal access token (PAT) / OAuth via credential manager | Key pair, public half uploaded to host |
| Corporate firewall/proxy | Usually works | Port 22 often blocked (try `ssh.github.com:443`) |
| Setup | Credential manager does it | One-time key generation |

> **Account passwords no longer work for Git over HTTPS** on GitHub (and increasingly elsewhere). Use a token or a credential manager.

## SSH setup

```bash
ssh-keygen -t ed25519 -C "you@example.com"          # accept default path, set a passphrase
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519  # load into agent
cat ~/.ssh/id_ed25519.pub                            # paste into GitHub/GitLab → SSH keys
ssh -T git@github.com                                # test: "Hi <user>! You've successfully authenticated"
```

Switch an existing clone to SSH: `git remote set-url origin git@github.com:owner/repo.git`

### Multiple accounts (work + personal) — `~/.ssh/config`

```sshconfig
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

```bash
git clone git@github-work:company/repo.git
```

Or per repo: `git config core.sshCommand "ssh -i ~/.ssh/id_ed25519_work -o IdentitiesOnly=yes"`

### SSH over port 443 (blocked port 22)

```sshconfig
Host github.com
    HostName ssh.github.com
    Port 443
    User git
```

### Debugging SSH

```bash
ssh -vT git@github.com
GIT_SSH_COMMAND="ssh -v" git fetch
```

## HTTPS credential helpers

```bash
# Windows / macOS / Linux: Git Credential Manager (handles OAuth, 2FA)
git config --global credential.helper manager
# macOS keychain
git config --global credential.helper osxkeychain
# Linux libsecret
git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
# cache in memory for 1h
git config --global credential.helper 'cache --timeout=3600'
```

Avoid `credential.helper store` — it writes tokens to `~/.git-credentials` in **plain text**.

Clear a cached bad credential:

```bash
printf "protocol=https\nhost=github.com\n\n" | git credential reject
```

Also: GitHub CLI `gh auth login` configures Git credentials for you.

**Never** put a token in the remote URL (`https://user:token@…`) — it ends up in `.git/config`, shell history, and logs.

## Proxies

```bash
git config --global http.proxy http://proxy.corp:8080
git config --global https.proxy http://proxy.corp:8080
git config --global http.https://internal.git.corp.proxy ""   # no proxy for one host
git config --global --unset http.proxy
```

Corporate TLS inspection → *"SSL certificate problem: unable to get local issuer certificate"*. Fix by trusting the corporate CA, **not** by disabling verification:

```bash
git config --global http.sslCAInfo /path/to/corp-ca-bundle.pem
# Windows alternative: use the OS certificate store
git config --global http.sslBackend schannel
```

## Signing commits and tags

Proves a commit really came from you ("Verified" badge).

### With SSH keys (simplest, Git ≥ 2.34)

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

Upload the same public key to your host as a **signing key**. For local verification:

```bash
echo "$(git config user.email) $(cat ~/.ssh/id_ed25519.pub)" >> ~/.ssh/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
git log --show-signature -1
```

### With GPG

```bash
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long
git config --global user.signingkey <KEYID>
git config --global commit.gpgsign true
gpg --armor --export <KEYID>        # upload to host
# "gpg failed to sign the data" → export GPG_TTY=$(tty)
```

## Leaked a secret

1. **Revoke/rotate the secret immediately.** Assume it's compromised the moment it was pushed — bots scrape public repos within minutes.
2. Remove it from history:
   ```bash
   git filter-repo --path config/secrets.env --invert-paths
   # or replace the string everywhere:
   echo 'MY_SECRET_VALUE==>REMOVED' > replacements.txt
   git filter-repo --replace-text replacements.txt
   ```
3. Force-push all affected branches and tags; ask everyone to re-clone.
4. Ask the host to purge cached views / PR refs if needed (forks and caches may retain it).
5. Prevent recurrence: secret scanning (GitHub push protection, `gitleaks`, `trufflehog`) in a pre-commit hook and CI; `.env` in `.gitignore`; commit only `.env.example`.

## Other security notes

- `git config --global transfer.fsckObjects true` — validate received objects.
- Be careful running hooks/scripts from untrusted repos; Git refuses repos owned by other users (`safe.directory`) for this reason:
  ```bash
  git config --global --add safe.directory /path/to/repo    # only if you trust it
  ```
- Don't commit customer data, NDAs, PDK files or vendor IP into public repos — license restrictions apply even when "it's just for my thesis".

## Next

→ [14 · Configuration & aliases](14-configuration-and-aliases.md)
