# What this is (and what it isn't)

## The honest explanation

This repo is a thin wrapper around [Claude Code](https://claude.ai/code) — Anthropic's AI coding agent — that points it at a different API endpoint instead of Anthropic's hosted service.

Claude Code normally calls `https://api.anthropic.com`. By setting the `ANTHROPIC_BASE_URL` environment variable, you redirect those calls to any server that speaks the same [Anthropic Messages API](https://docs.anthropic.com/en/api/messages) format.

That local server can run an open-weight model (Llama, Mistral, Qwen, Phi, etc.) or proxy to another service. You provide the model. Claude Code provides the agentic coding layer: file reading, editing, bash execution, search, and conversation context.

## What changes when you use a local endpoint

| Thing | Anthropic-hosted | Local endpoint |
|---|---|---|
| Model identity | Claude (Haiku/Sonnet/Opus) | Whatever you're running |
| Coding quality | High | Varies — often lower |
| Safety filters | Anthropic's built-in | Depends on the model/server |
| API cost | Per token | Your hardware / hosting |
| Data stays local | No (sent to Anthropic) | Yes, if fully local |
| Latency | Network round-trip | Local — can be fast or slow |

## What doesn't change

- The Claude Code CLI itself: all its tools, slash commands, and keyboard shortcuts work the same.
- How Claude Code formats its requests: it still sends Anthropic Messages API format JSON.
- Your project files: Claude Code reads and edits them exactly as it would with a hosted model.

## Common misconceptions

**"This lets me run Claude for free."**
No. You're not running Claude — you're running a different model (or a gateway). The Claude Code *tool* still requires an Anthropic account if you use it in its normal interactive mode, though the API calls are redirected.

**"Any local model will work just as well."**
No. Claude Code is optimized for Claude's instruction-following and tool-use behavior. Smaller or less capable models may misunderstand instructions, format tool calls incorrectly, or produce lower-quality code. Results vary significantly by model.

**"This bypasses Anthropic's safety measures."**
Redirecting the API endpoint does mean you're no longer using Anthropic's safety systems for the model responses. You are responsible for what happens when you run a local model. See [safety-notes.md](safety-notes.md).

## When this setup makes sense

- Air-gapped or offline development environments
- Organizations with data residency requirements
- Experimenting with open-weight models as coding agents
- Cost-conscious prototyping where cloud API costs are a concern
- Research into how different models perform on agentic coding tasks
