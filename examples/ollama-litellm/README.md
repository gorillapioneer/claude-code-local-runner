# Example: Ollama + LiteLLM proxy

This example shows how to run Claude Code against a local [Ollama](https://ollama.com) model using [LiteLLM](https://github.com/BerriAI/litellm) as a translation proxy.

**What you get:** Claude Code as the coding agent, with a locally-running open-weight model (Llama, Mistral, Qwen, etc.) answering its requests — all on your own machine.

**What this is not:** This does not run Anthropic's Claude models locally. The model quality will differ from Anthropic's hosted service. Local model performance on complex agentic tasks varies significantly.

---

## Why you need LiteLLM

Ollama serves models using the **OpenAI** API format (`/v1/chat/completions`).

Claude Code sends requests in the **Anthropic** API format (`/v1/messages`).

These are different. Claude Code cannot talk to Ollama directly. LiteLLM acts as a proxy that sits between them: it accepts Anthropic-format requests from Claude Code and forwards them to Ollama in OpenAI format.

```
Claude Code
    |
    | (Anthropic Messages API format)
    v
LiteLLM proxy  :4000
    |
    | (OpenAI format)
    v
Ollama  :11434
    |
    v
Your local model (llama3, mistral, etc.)
```

---

## Step 1 — Install Ollama

Download and install Ollama from [ollama.com](https://ollama.com).

On Windows, Ollama installs as a system service and starts automatically. Verify it's running:

```powershell
ollama list
```

---

## Step 2 — Pull a model

```powershell
ollama pull llama3.2
```

You can use any model Ollama supports. For coding tasks, larger models generally perform better. Some options to try:

| Model | Pull command | Notes |
|---|---|---|
| Llama 3.2 (3B) | `ollama pull llama3.2` | Small and fast; limited on complex tasks |
| Llama 3.1 (8B) | `ollama pull llama3.1` | Better balance of speed and quality |
| Qwen2.5-Coder (7B) | `ollama pull qwen2.5-coder` | Fine-tuned for code |
| Mistral (7B) | `ollama pull mistral` | Good general-purpose option |

Confirm the model downloaded:

```powershell
ollama list
```

---

## Step 3 — Install LiteLLM

LiteLLM is a Python package. You need Python 3.8+ installed.

```powershell
pip install 'litellm[proxy]'
```

Verify:

```powershell
litellm --version
```

---

## Step 4 — Start the LiteLLM proxy

From the repo root, start LiteLLM using the provided config file:

```powershell
litellm --config examples/ollama-litellm/litellm_config.yaml --port 4000
```

You should see output like:

```
INFO: Started server process
INFO: Uvicorn running on http://0.0.0.0:4000
```

Leave this terminal open — LiteLLM needs to keep running while you use Claude Code.

To use a different model, edit `litellm_config.yaml` and change the `model` and `model_name` values to match the model you pulled in Step 2.

---

## Step 5 — Configure your `.env`

In a new terminal, from the repo root:

```powershell
# If you haven't already
Copy-Item .env.example .env
notepad .env
```

Set these values:

```
ANTHROPIC_BASE_URL=http://localhost:4000
ANTHROPIC_API_KEY=dummy
ANTHROPIC_MODEL=llama3.2
```

`ANTHROPIC_MODEL` should match the `model_name` you set in `litellm_config.yaml`.

---

## Step 6 — Check the endpoint

```powershell
.\scripts\check-endpoint.ps1
```

A working setup prints:

```
[OK] Endpoint responded with HTTP 200

Available models:
  - llama3.2
```

---

## Step 7 — Start Claude Code

```powershell
.\scripts\run-claude-local.ps1
```

Claude Code launches and routes all model calls through LiteLLM to Ollama.

---

## Notes on model quality

Open-weight models behave differently from Anthropic's Claude. In practice:

- Smaller models (3B–7B) often struggle with multi-step agentic tasks, complex refactors, or precise tool-call formatting.
- If Claude Code seems to loop, ignore instructions, or produce garbled file edits, the model may not be following the tool-use schema correctly. Try a larger or coding-focused model.
- The `examples/CLAUDE.md` file in this repo contains a conservative instruction set that constrains the agent to read-only tasks until you've verified your model is working reliably.

---

## Stopping the proxy

When you're done, stop LiteLLM with `Ctrl+C` in the terminal where it's running.
