# claude-code-local-runner

Run [Claude Code](https://claude.ai/code) against a local or self-hosted model endpoint — no Anthropic cloud required for the model backend.

---

## What this is

Claude Code is Anthropic's AI coding agent (CLI). By default it calls Anthropic's hosted API. This repo shows how to point it at a **different** Anthropic-compatible endpoint using the `ANTHROPIC_BASE_URL` environment variable.

That endpoint can be:
- A local model server (vLLM, Ollama with an OpenAI-compat layer + LiteLLM proxy, etc.)
- A Docker Model Runner
- LiteLLM in proxy mode
- Any gateway that speaks the Anthropic Messages API

You still run **Claude Code** as the agent. The model that answers its requests comes from wherever you point `ANTHROPIC_BASE_URL`.

## What this is NOT

- This does **not** run Anthropic's Claude models locally for free.
- This does **not** bypass Anthropic's terms of service for models you don't have rights to use.
- Local open-weight model quality is substantially different from Anthropic's hosted Claude models. Expect different (often worse) results on complex coding tasks.
- This is not an official Anthropic product or guide.

---

## Quick start — Windows PowerShell

```powershell
# 1. Copy the example env file
Copy-Item .env.example .env

# 2. Edit .env with your endpoint URL
notepad .env

# 3. Load the vars and start Claude Code
. .\scripts\run-claude-local.ps1
```

## Quick start — Bash (Linux / macOS / WSL)

```bash
# 1. Copy the example env file
cp .env.example .env

# 2. Edit .env with your endpoint URL
nano .env   # or your preferred editor

# 3. Make the script executable and run it
chmod +x scripts/run-claude-local.sh
./scripts/run-claude-local.sh
```

---

## How ANTHROPIC_BASE_URL works

Claude Code's underlying SDK checks the `ANTHROPIC_BASE_URL` environment variable before it makes any API call. When set, every request goes to that base URL instead of `https://api.anthropic.com`.

```
ANTHROPIC_BASE_URL=http://localhost:8080
  -> requests go to http://localhost:8080/v1/messages
                    http://localhost:8080/v1/models
                    etc.
```

The variable must be set **before** you launch `claude`. The helper scripts in this repo handle that.

## Why your endpoint must support the Anthropic Messages API

Claude Code doesn't speak OpenAI's `/v1/chat/completions` format. It uses Anthropic's `/v1/messages` format with Anthropic-specific fields (`system` as a top-level key, `content` arrays, tool use blocks, etc.).

If your local server speaks only the OpenAI format, you need a translation layer. [LiteLLM](https://github.com/BerriAI/litellm) in proxy mode is the most common choice — it can accept Anthropic-format requests and forward them to almost any backend.

---

## Example endpoint URLs

| Setup | ANTHROPIC_BASE_URL |
|---|---|
| vLLM (default port) | `http://localhost:8000` |
| Ollama + LiteLLM proxy | `http://localhost:4000` |
| Docker Model Runner | `http://localhost:12434/engines/llama.cpp/v1` |
| LiteLLM standalone | `http://localhost:4000` |
| Remote self-hosted gateway | `https://your-gateway.example.com` |

See [docs/model-endpoints.md](docs/model-endpoints.md) for setup notes for each option.

---

## Verifying your endpoint

```powershell
# PowerShell
.\scripts\check-endpoint.ps1
```

```bash
# Bash
bash scripts/check-endpoint.sh
```

This hits `/v1/models` on your configured base URL and prints what it finds.

---

## Troubleshooting

**`Error: ECONNREFUSED` or `connect ECONNREFUSED`**
Your endpoint isn't running or isn't on the port you specified. Start your model server first, then re-run the helper script.

**`401 Unauthorized`**
Your local server is checking `ANTHROPIC_API_KEY`. Set it to whatever value your server expects (often `"dummy"` or a token you configured).

**`404 Not Found` on `/v1/messages`**
Your server doesn't implement the Anthropic Messages API. You likely need a LiteLLM proxy in front of it.

**Claude Code responds strangely or ignores instructions**
Local model quality varies. Smaller models may not follow complex agentic instructions reliably. Try a larger model or one fine-tuned for instruction following.

**`ANTHROPIC_BASE_URL` is ignored**
Make sure you set it *before* launching `claude`, in the same shell session. The helper scripts do this automatically. Verify with `echo $env:ANTHROPIC_BASE_URL` (PowerShell) or `echo $ANTHROPIC_BASE_URL` (Bash).

---

## Safety notes

When Claude Code runs against a local model, the usual hosted safety guardrails may not be present. Read [docs/safety-notes.md](docs/safety-notes.md) before using this in sensitive environments. The [examples/CLAUDE.md](examples/CLAUDE.md) file shows a conservative instruction set you can copy into your project.

---

## License

MIT. See [LICENSE](LICENSE).
