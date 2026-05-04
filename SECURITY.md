# Security

## What to never commit

The most common security mistake in repos like this one is accidentally committing secrets. Before every commit, check that none of the following are present in your staged files:

**API keys and tokens**
- `.env` files of any kind — these are gitignored by default, but `git add -f` can force them in
- Any file containing a real value for `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, or any other credential
- Bearer tokens, session tokens, or passwords in any file

**Private infrastructure details**
- Internal hostnames, IP addresses, or URLs that point to your private network
- Port numbers or service names that reveal your internal architecture
- Paths that include your username or machine name (e.g. `C:\Users\yourname\...`)

**Logs and terminal output**
- Log files that contain request/response bodies — these can contain prompt content or API responses that include sensitive data
- Screenshots or terminal recordings that show keys, tokens, or private paths

**Model configuration with secrets**
- `litellm_config.yaml` or similar files that have been modified to include real credentials or private API base URLs

---

## The `.env` file

The `.env` file is gitignored by design. Only `.env.example` — which contains no real values — should ever be committed.

If you want to share your configuration with someone, copy `.env.example`, fill in placeholder values that make the structure clear, and share that copy. Never share your actual `.env`.

---

## If you accidentally commit a secret

Deleting the secret in a follow-up commit is **not enough** — git history preserves deleted content and it can be recovered.

Steps to take:
1. **Rotate the secret immediately.** Revoke the key or token at its source before doing anything else.
2. Rewrite git history to remove the secret (e.g. using `git filter-repo` or BFG Repo Cleaner).
3. Force-push the cleaned history.
4. Notify any collaborators who may have cloned or forked the repo with the exposed history.

GitHub also has a secret scanning feature that will alert you if a known secret format (e.g. an Anthropic API key) appears in a push.

---

## Local model endpoints and trust

When you set `ANTHROPIC_BASE_URL` to a remote address, every request Claude Code makes — including the full content of files it reads — is sent to that endpoint. Only point `ANTHROPIC_BASE_URL` at servers you trust and control.

A compromised or malicious endpoint could:
- Log the contents of every file Claude Code sends it
- Inject instructions into model responses to manipulate the agent's behavior

For sensitive codebases, only use a fully local endpoint (`localhost`) and keep `ANTHROPIC_BASE_URL` pointing there.

---

## Reporting a vulnerability

If you find a security issue in this repo (e.g. a script that exposes secrets, an example config that handles credentials unsafely), please open a GitHub issue with the label `security`. Describe what you found and, if possible, a suggested fix. Do not include reproduction steps that require publishing a real secret.

This repo does not contain production services, so the risk surface is primarily documentation accuracy and script safety rather than running infrastructure.
