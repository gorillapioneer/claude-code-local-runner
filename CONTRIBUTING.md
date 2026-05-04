# Contributing

Thanks for your interest in improving this project. Contributions are welcome — especially docs, examples, and corrections.

---

## What this repo is

A starter template showing how to run [Claude Code](https://claude.ai/code) against a local or self-hosted Anthropic-compatible endpoint via `ANTHROPIC_BASE_URL`. It is not a framework, not a fork of Claude Code, and does not bundle any model weights or Anthropic software.

Keeping that scope in mind helps decide whether a contribution belongs here or in a separate project.

---

## Ways to contribute

- **Fix a doc error** — typos, outdated instructions, broken links
- **Add an endpoint example** — a new `examples/<setup-name>/` directory showing how to wire up a specific model server
- **Improve a script** — better error messages, edge case handling, cross-platform fixes
- **Report a bug** — use the bug report issue template
- **Suggest a feature** — use the feature request issue template

---

## Before you start

For small fixes (typos, one-line corrections), just open a PR directly.

For anything larger — a new example directory, a significant doc rewrite, a new script — open an issue first to describe what you're planning. This avoids duplicated effort and keeps the scope focused.

---

## Adding a new example

Examples live in `examples/<setup-name>/`. Each example directory should contain:

- `README.md` — step-by-step instructions for that specific setup
- Any config files needed (e.g. `litellm_config.yaml`, `docker-compose.yml`)

Guidelines:
- Be honest about what the setup does and doesn't do. Do not claim it runs Anthropic's Claude models locally for free.
- Include a short "what this is not" or "notes on model quality" section so readers have realistic expectations.
- Keep the instructions beginner-friendly — assume the reader knows how to use a terminal but not necessarily how LLM serving works.
- Don't include model weights, proprietary software, or anything that requires a paid account to use (unless clearly noted).

---

## Adding or editing documentation

Docs live in `docs/`. When editing:

- Link to other doc files using relative paths (e.g. `[safety notes](safety-notes.md)`).
- If you add a new doc, add a link to it from the relevant section of `README.md` or another doc that would naturally point to it.
- Keep language plain and accurate. Avoid marketing language.

---

## Safety checklist before opening a PR

Before submitting, make sure your changes don't include any of the following:

- [ ] `.env` files or any file containing real API keys or tokens
- [ ] Logs, terminal output, or screenshots that show secrets, tokens, or private paths
- [ ] Hardcoded IP addresses, hostnames, or URLs from your private network
- [ ] Any credentials, even ones that look placeholder-ish but happen to be real

If you accidentally committed a secret, rotate it immediately — do not just delete it in a follow-up commit, because git history preserves it.

See [SECURITY.md](SECURITY.md) for more detail.

---

## Pull request process

1. Fork the repo and create a branch from `main`.
2. Make your changes.
3. Run through the safety checklist above.
4. Open a PR with a clear title and a one-paragraph description of what changed and why.
5. A maintainer will review and may ask for adjustments before merging.

---

## Code style

Scripts should follow the conventions already in the repo:

- **PowerShell:** use `Write-Host` with `-ForegroundColor` for user-facing output; use `[System.Environment]::GetEnvironmentVariable` for env var reads that don't conflict with already-set vars.
- **Bash:** `set -euo pipefail` at the top; POSIX-compatible where possible.
- **YAML:** 2-space indent; comment every non-obvious field.
- **Markdown:** ATX headings (`##`), fenced code blocks with language tags.

No strict linter is enforced — just aim for consistency with the existing files.
