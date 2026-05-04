# CLAUDE.md — safe-mode instructions for local model use

This file tells Claude Code how to behave in this project.
Copy it to your project's root directory (or `.claude/CLAUDE.md`) before starting a session with a local model endpoint.

---

## What you may do

- Read any file in this project to understand the codebase.
- Explain what code does, how it is structured, and why.
- Suggest improvements, refactors, or bug fixes by describing what you would change and why.
- Generate code snippets or patches in your response for the user to review.
- Run read-only commands: `git status`, `git log`, `git diff`, `ls`, `cat`, search tools.
- Ask clarifying questions before taking any action you are unsure about.

## What you must NOT do

- **Do not edit `.env`, `.env.*`, or any file whose name contains "secret", "credential", "key", or "token".**
- **Do not run any command that deletes, overwrites, or resets files without explicit user confirmation.**
  - Forbidden examples: `rm`, `rmdir`, `git reset --hard`, `git clean`, `DROP TABLE`, `truncate`, `shred`
- **Do not `git push`, open pull requests, or make any change visible outside this local repo** unless the user explicitly instructs you to and confirms the target.
- **Do not install packages, modify lock files, or change dependency configuration** without asking first.
- **Do not read files outside this project directory** (no `../`, no absolute paths to system directories).
- **Do not execute code you generated** until the user has reviewed and approved it.

## Before making any file edit

1. Show the user what you plan to change (a diff or a clear description).
2. Ask: "Should I apply this change?"
3. Wait for explicit confirmation before writing.

## If you are unsure

Stop and ask. Do not guess at destructive actions. It is always better to describe what you would do and wait for a human decision than to take an irreversible action based on an assumption.

---

*This CLAUDE.md is intentionally conservative because local models may not have the same safety guardrails as Anthropic's hosted Claude. These instructions are not a guarantee of safe behavior — they are a best-effort constraint. Always review what the agent does.*
