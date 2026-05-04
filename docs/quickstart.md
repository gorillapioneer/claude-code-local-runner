# Quickstart

Get Claude Code running against a local model endpoint in five steps.

> **What this does:** Points Claude Code — Anthropic's AI coding agent — at a local or self-hosted model server instead of Anthropic's hosted API. The model behind it is whatever you're running locally. This is not free access to Anthropic's Claude models.

---

## Prerequisites

- [Claude Code](https://claude.ai/code) installed (`npm install -g @anthropic-ai/claude-code`)
- A running local model endpoint that speaks the [Anthropic Messages API](https://docs.anthropic.com/en/api/messages) format

If you don't have an endpoint yet, the [Ollama + LiteLLM example](../examples/ollama-litellm/README.md) is the easiest way to get one running locally.

---

## Steps

**1. Copy the env file**

```bash
# Bash / WSL / macOS
cp .env.example .env

# PowerShell
Copy-Item .env.example .env
```

**2. Set your endpoint URL**

Open `.env` and set `ANTHROPIC_BASE_URL` to your model server's address:

```
ANTHROPIC_BASE_URL=http://localhost:4000
ANTHROPIC_API_KEY=dummy
```

**3. Check the endpoint is reachable**

```bash
# Bash
bash scripts/run-claude-local.sh --check   # or just run check-endpoint manually
```

```powershell
# PowerShell
.\scripts\check-endpoint.ps1
```

You should see `[OK] Endpoint responded with HTTP 200`. If not, start your model server first.

**4. Start Claude Code**

```bash
# Bash
./scripts/run-claude-local.sh
```

```powershell
# PowerShell
.\scripts\run-claude-local.ps1
```

**5. Try it**

At the Claude Code prompt, ask something simple first — like "list the files in this directory" — to confirm the model is responding before you ask it to edit anything.

---

## What to expect

Local model quality varies. Smaller models may struggle with complex multi-step tasks or produce garbled tool calls. If Claude Code loops or ignores instructions, try a larger or coding-focused model.

For a safer starting point, copy `examples/CLAUDE.md` into your project root. It constrains the agent to read-only tasks until you're confident in your setup.

---

## Deeper guides

- [Full Windows setup walkthrough](windows-setup.md) — detailed steps, execution policy, and troubleshooting
- [Ollama + LiteLLM example](../examples/ollama-litellm/README.md) — full worked example for running a local model
- [Model endpoint options](model-endpoints.md) — vLLM, Docker Model Runner, LiteLLM, remote gateways
- [Safety notes](safety-notes.md) — what changes when you're not using Anthropic's hosted safety layer
