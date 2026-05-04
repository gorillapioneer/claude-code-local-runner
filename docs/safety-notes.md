# Safety notes

## The core risk

Claude Code is an agentic tool. It reads files, runs bash commands, edits code, and can take actions that are hard to reverse. When you point it at a hosted Claude model, Anthropic's safety systems help filter harmful outputs and refuse dangerous instructions.

When you point it at a local or third-party model, **those safety systems are not present** unless the model or server you're using provides equivalent ones.

This doesn't mean local models are inherently dangerous — but it does mean you are taking on more responsibility for what the agent does.

## Concrete risks

**A less capable model may misunderstand scope.**
If you ask the agent to "refactor the auth module," a weaker model might edit more files than intended, delete things, or make structurally wrong changes that break the build.

**A poorly aligned model may ignore safety instructions.**
Some open-weight models will comply with instructions that Claude would normally refuse. Be careful what you ask.

**Tool use reliability varies.**
Claude Code relies on the model correctly formatting tool calls (file edits, bash commands). Models that don't follow the tool-call schema reliably can produce garbled edits or unexpected shell commands.

## Mitigations

**Use the safe-mode CLAUDE.md from `examples/`.**
Copying `examples/CLAUDE.md` into your project's root (or `.claude/CLAUDE.md`) tells Claude Code — regardless of which model is behind it — to stick to inspection, explanation, and suggestions, and to ask before making changes.

**Run in a throwaway environment.**
Use a Docker container, a VM, or a fresh git branch. Never run an experimental agent setup directly against a production codebase.

**Keep `ANTHROPIC_BASE_URL` pointed at localhost.**
Avoid routing to remote endpoints you don't control. A compromised or malicious endpoint could inject instructions into model responses.

**Review every edit before accepting.**
Claude Code's diff view lets you review proposed changes. Use it. Don't blindly accept bulk edits from an unfamiliar model.

**Don't give the agent access to secrets.**
Keep `.env` files, credentials, and API keys out of the working directory the agent can read, or explicitly exclude them in your CLAUDE.md.

**Start with read-only tasks.**
Ask the model to explain or document code before you ask it to change anything. This lets you calibrate its reliability before granting it write access.

## The examples/CLAUDE.md file

The [examples/CLAUDE.md](../examples/CLAUDE.md) file in this repo is a conservative instruction set designed for exactly this scenario. It tells the agent:

- Read, explain, and suggest — but ask before editing
- Never touch `.env` or credential files
- Never run destructive commands (`rm -rf`, `DROP TABLE`, `git reset --hard`, etc.)
- Report what it would do rather than doing it

Copy it into your project root as `CLAUDE.md` for a safer starting point.
