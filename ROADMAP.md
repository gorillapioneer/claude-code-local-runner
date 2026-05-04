# Roadmap

This project is a small public starter kit for running Claude Code against local or self-hosted Anthropic-compatible model endpoints.

The aim is to keep it honest, simple, and useful for people experimenting with local models, gateways, and coding agents.

## v0.1 — Starter kit

Status: mostly complete

- [x] Basic README
- [x] Windows PowerShell launcher
- [x] Bash launcher
- [x] PowerShell endpoint checker
- [x] Bash endpoint checker
- [x] `.env.example`
- [x] Safety notes
- [x] Model endpoint notes

## v0.2 — Better examples

Planned:

- [ ] Add an Ollama + LiteLLM example config
- [ ] Add a Docker Model Runner example
- [ ] Add a vLLM example
- [ ] Add a tiny demo project Claude Code can safely edit
- [ ] Add a `CLAUDE.md` safe-mode template for real projects

## v0.3 — Better setup experience

Planned:

- [ ] Add a Windows setup checklist
- [ ] Add a Linux/macOS setup checklist
- [ ] Add common failure examples and fixes
- [ ] Add screenshots or terminal examples
- [ ] Add a compatibility table for tested backends

## v0.4 — Contributor polish

Planned:

- [ ] Add `CONTRIBUTING.md`
- [ ] Add issue templates
- [ ] Add pull request template
- [ ] Add shell script linting notes
- [ ] Add a basic GitHub Actions check for Markdown links and shell syntax

## Project principles

1. Do not imply Anthropic Claude models run locally for free.
2. Keep examples beginner-friendly.
3. Do not encourage unsafe agent behaviour.
4. Prefer small, reviewable scripts over magic installers.
5. Make Windows support first-class, not an afterthought.
