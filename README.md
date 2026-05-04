# claude-code-local-runner

Use [Claude Code](https://claude.ai/code) as your terminal coding agent, routed to a local or self-hosted Anthropic-compatible endpoint instead of Anthropic's hosted API.

> **Not sure what that means?** See [docs/quickstart.md](docs/quickstart.md) — it explains the idea in plain language and gets you running in five steps.

---

## Start here

| Guide | What it covers |
|---|---|
| [docs/quickstart.md](docs/quickstart.md) | Five-step setup for any platform |
| [docs/windows-setup.md](docs/windows-setup.md) | Detailed Windows + PowerShell walkthrough with troubleshooting |
| [examples/ollama-litellm/](examples/ollama-litellm/README.md) | Full worked example: local model via Ollama + LiteLLM proxy |
| [docs/model-endpoints.md](docs/model-endpoints.md) | All supported endpoint types: vLLM, Docker Model Runner, LiteLLM, remote gateways |

---

## Who this is for

- Developers who want to run Claude Code against a **local or self-hosted model** — for privacy, offline use, or cost reasons
- Teams with **data residency requirements** who can't send code to Anthropic's hosted API
- Anyone **experimenting with open-weight models** as agentic coding assistants
- Researchers comparing how different model backends perform on real coding tasks

---

## What this is not

- **Not free access to Anthropic's Claude models.** The model backend is whatever you're running locally — an open-weight model, a self-hosted gateway, or a third-party service. Claude Code is the coding agent; it does not include a model.
- **Not an official Anthropic product.** This is an independent starter template.
- **Not a guarantee of Claude-quality results.** Local open-weight models behave differently from Anthropic's hosted Claude. Expect lower reliability on complex multi-step tasks, especially with smaller models.
- **Not a way to bypass Anthropic's terms of service** for models you don't have rights to use.

---

## How it works

Claude Code checks the `ANTHROPIC_BASE_URL` environment variable before making any API call. When set, every request goes to that address instead of `https://api.anthropic.com`.

```
ANTHROPIC_BASE_URL=http://localhost:4000
  -> Claude Code sends requests to http://localhost:4000/v1/messages
```

Your local model server must speak the **Anthropic Messages API format** at `/v1/messages`. If it only speaks the OpenAI format (e.g. plain Ollama or plain vLLM), you need [LiteLLM](https://github.com/BerriAI/litellm) as a translation proxy in front of it. The [Ollama + LiteLLM example](examples/ollama-litellm/README.md) shows exactly how to do this.

The helper scripts in this repo set `ANTHROPIC_BASE_URL` from your `.env` file and launch `claude` — that's the main thing they do.

---

## Quick start

```bash
# Bash (Linux / macOS / WSL)
cp .env.example .env
# edit .env: set ANTHROPIC_BASE_URL to your endpoint
chmod +x scripts/run-claude-local.sh
./scripts/run-claude-local.sh
```

```powershell
# PowerShell (Windows)
Copy-Item .env.example .env
# edit .env: set ANTHROPIC_BASE_URL to your endpoint
.\scripts\run-claude-local.ps1
```

Check your endpoint is reachable before starting:

```bash
bash scripts/check-endpoint.sh         # Bash
.\scripts\check-endpoint.ps1           # PowerShell
```

---

## Example endpoint URLs

| Setup | `ANTHROPIC_BASE_URL` |
|---|---|
| vLLM | `http://localhost:8000` |
| Ollama + LiteLLM proxy | `http://localhost:4000` |
| Docker Model Runner | `http://localhost:12434/engines/llama.cpp/v1` |
| LiteLLM standalone | `http://localhost:4000` |
| Remote self-hosted gateway | `https://your-gateway.example.com` |

---

## Current examples

| Example | Description |
|---|---|
| [examples/ollama-litellm/](examples/ollama-litellm/README.md) | Local Ollama model with LiteLLM as an Anthropic-format proxy |
| [examples/vllm/](examples/vllm/README.md) | vLLM inference server, with or without a LiteLLM proxy |
| [examples/docker-model-runner/](examples/docker-model-runner/README.md) | Docker Desktop's built-in model runner via LiteLLM proxy |
| [examples/CLAUDE.md](examples/CLAUDE.md) | Safe-mode CLAUDE.md to constrain the agent in untested setups |

---

## Roadmap

Planned examples and improvements — contributions welcome:

- [x] Ollama + LiteLLM example
- [x] vLLM example
- [x] Docker Model Runner example
- [ ] LiteLLM cloud gateway example (route to Bedrock, Vertex, or Azure)
- [ ] Expanded endpoint compatibility tests

---

## Troubleshooting

**`connect ECONNREFUSED`**
Your model server isn't running or is on a different port. Start it first, then re-run the check script.

**`401 Unauthorized`**
Your server is checking the API key. Set `ANTHROPIC_API_KEY` in `.env` to whatever value your server expects — usually `dummy` or a token you configured at startup.

**`404` on `/v1/messages` or `/v1/models`**
Your server doesn't implement the Anthropic Messages API. Add a LiteLLM proxy in front of it. See [examples/ollama-litellm/](examples/ollama-litellm/README.md).

**Claude Code loops or ignores instructions**
Local model quality varies. Smaller models often can't follow complex agentic tool-use reliably. Try a larger or coding-focused model (see [docs/model-endpoints.md](docs/model-endpoints.md)).

**`ANTHROPIC_BASE_URL` is ignored**
It must be set *before* `claude` launches. The helper scripts handle this from `.env`. Verify with `echo $env:ANTHROPIC_BASE_URL` (PowerShell) or `echo $ANTHROPIC_BASE_URL` (Bash).

---

## Safety and limitations

Running Claude Code against a local model means Anthropic's hosted safety guardrails are not in the loop. Read [docs/safety-notes.md](docs/safety-notes.md) before using this on a sensitive codebase.

Never commit `.env` files, API keys, or logs with secrets. See [SECURITY.md](SECURITY.md) for the full checklist.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add examples, fix docs, and submit PRs safely.

---

## License

MIT. See [LICENSE](LICENSE).
