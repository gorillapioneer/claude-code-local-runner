# Example: vLLM

This example shows how to route Claude Code to a [vLLM](https://github.com/vllm-project/vllm) model server via `ANTHROPIC_BASE_URL`.

**What you get:** Claude Code as the terminal coding agent, sending requests to a vLLM instance running a local open-weight model.

**What this is not:** This does not run Anthropic's Claude models. The model quality depends entirely on what you load into vLLM. Results on complex agentic coding tasks will vary.

---

## What is vLLM?

vLLM is an open-source, high-throughput inference engine for large language models. It can serve many open-weight models (Llama, Mistral, Qwen, DeepSeek, etc.) over HTTP.

By default, vLLM exposes an **OpenAI-compatible** API (`/v1/chat/completions`). Claude Code does **not** speak the OpenAI format — it sends requests in the **Anthropic Messages API** format (`/v1/messages`).

This means you usually need either:
1. A translation proxy (LiteLLM) between vLLM and Claude Code, **or**
2. A vLLM build or plugin that natively exposes an Anthropic-format endpoint

---

## Option A — vLLM + LiteLLM proxy (recommended for most setups)

This is the most straightforward approach. LiteLLM accepts Anthropic-format requests from Claude Code and forwards them to vLLM in OpenAI format.

```
Claude Code
    |  (Anthropic Messages API)
    v
LiteLLM proxy  :4000
    |  (OpenAI format)
    v
vLLM  :8000
    |
    v
Your model (Llama, Mistral, Qwen, etc.)
```

### Step 1 — Start vLLM

```bash
# Example only — adjust model name and hardware flags for your setup
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-3.1-8B-Instruct \
  --port 8000
```

> vLLM requires a CUDA-capable GPU or a CPU build. Refer to the [vLLM installation docs](https://docs.vllm.ai/en/latest/getting_started/installation.html) for your hardware.

Confirm vLLM is running:

```bash
curl http://localhost:8000/v1/models
```

You should see a JSON list with your model name.

### Step 2 — Install LiteLLM

```bash
pip install 'litellm[proxy]'
```

### Step 3 — Create a LiteLLM config

Create `litellm_config.yaml` (you can place it anywhere):

```yaml
model_list:
  - model_name: llama3.1-8b
    litellm_params:
      model: openai/meta-llama/Llama-3.1-8B-Instruct
      api_base: http://localhost:8000
      api_key: dummy

litellm_settings:
  drop_params: true
```

Replace `model_name` and the `model` value with whatever you're actually serving in vLLM. The `model_name` is what you'll set in `ANTHROPIC_MODEL`; the `model` value must match the model ID vLLM reports at `/v1/models`.

### Step 4 — Start LiteLLM

```bash
litellm --config litellm_config.yaml --port 4000
```

### Step 5 — Configure `.env`

```
ANTHROPIC_BASE_URL=http://localhost:4000
ANTHROPIC_API_KEY=dummy
ANTHROPIC_MODEL=llama3.1-8b
```

### Step 6 — Verify and start Claude Code

```bash
bash scripts/check-endpoint.sh     # or .\scripts\check-endpoint.ps1
./scripts/run-claude-local.sh      # or .\scripts\run-claude-local.ps1
```

---

## Option B — vLLM with native Anthropic-format support

Some vLLM versions and community plugins expose `/v1/messages` directly. If your vLLM instance already speaks the Anthropic format, you can skip LiteLLM:

```
ANTHROPIC_BASE_URL=http://localhost:8000
```

Check by probing the endpoint directly:

```bash
curl http://localhost:8000/v1/models
```

Then run the check script and look for a 200 response. If you get a 404 on `/v1/messages` when Claude Code tries to connect, fall back to Option A.

---

## Notes on model quality

vLLM runs whatever model you load into it. Claude Code was designed around Claude's instruction-following and tool-use behavior. Open-weight models vary significantly in how well they follow agentic tool-call schemas.

Practical guidance:
- Models smaller than ~7B parameters often struggle with multi-step agentic tasks.
- Coding-focused fine-tunes (Qwen2.5-Coder, DeepSeek-Coder) tend to perform better than general-purpose models of the same size.
- If Claude Code produces garbled file edits or loops, the model may not be formatting tool calls correctly. Try a larger model.

For a conservative starting point, copy [examples/CLAUDE.md](../CLAUDE.md) into your project root. It restricts the agent to read-only tasks until you've verified your model is reliable.

---

## Troubleshooting

**`connect ECONNREFUSED` on port 8000**
vLLM isn't running. Start it and wait for the "Uvicorn running" log line before retrying.

**`connect ECONNREFUSED` on port 4000**
LiteLLM proxy isn't running. Start it in a separate terminal and keep it open.

**`404` on `/v1/messages`**
vLLM is serving OpenAI format only. Use LiteLLM (Option A) as the translation layer.

**`model not found` or `404` from LiteLLM**
The `model_name` in your LiteLLM config doesn't match `ANTHROPIC_MODEL` in `.env`, or the `model` value in the config doesn't match what vLLM reports at `/v1/models`. Check both.

**Out of memory / vLLM crashes on load**
The model is too large for your available VRAM. Try a smaller model or use vLLM's `--quantization` flag (e.g. `--quantization awq` or `--quantization bitsandbytes`).

**Claude Code ignores tool calls or produces wrong edits**
The loaded model may not follow Claude Code's tool-use schema reliably. Try a larger or coding-focused model.
