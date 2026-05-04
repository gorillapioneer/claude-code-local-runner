# Model endpoint setup

This page covers how to set up the most common local and self-hosted endpoint options so that Claude Code can talk to them.

The key requirement: your endpoint must accept **Anthropic Messages API format** requests at `/v1/messages`. If it only speaks the OpenAI format, you need a translation layer (see the LiteLLM section below).

---

## vLLM

vLLM can serve models in both OpenAI and (as of recent versions) Anthropic-compatible formats. Check your vLLM version's docs for `--api-format anthropic` or similar flags.

```bash
# Example: serve a Llama model with Anthropic-format API
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-3-8B-Instruct \
  --port 8000
```

Then add LiteLLM in front if vLLM doesn't natively support `/v1/messages` for your version (see LiteLLM section).

```
ANTHROPIC_BASE_URL=http://localhost:8000
```

---

## Ollama + LiteLLM proxy

Ollama runs models locally but speaks OpenAI format, not Anthropic format. Use LiteLLM as a translation proxy.

**Step 1: Start Ollama**
```bash
ollama pull llama3
ollama serve
# Ollama runs on http://localhost:11434
```

**Step 2: Install and configure LiteLLM**
```bash
pip install litellm[proxy]
```

Create `litellm_config.yaml`:
```yaml
model_list:
  - model_name: llama3
    litellm_params:
      model: ollama/llama3
      api_base: http://localhost:11434
```

**Step 3: Start LiteLLM proxy**
```bash
litellm --config litellm_config.yaml --port 4000
```

**Step 4: Set your env**
```
ANTHROPIC_BASE_URL=http://localhost:4000
ANTHROPIC_MODEL=llama3
```

---

## Docker Model Runner

Docker's built-in model runner (available in Docker Desktop 4.40+) serves models via a local HTTP endpoint.

```bash
# Pull and run a model
docker model pull ai/llama3.2
docker model run ai/llama3.2
```

The endpoint is typically:
```
ANTHROPIC_BASE_URL=http://localhost:12434/engines/llama.cpp/v1
```

Docker Model Runner uses OpenAI format, so you may still need LiteLLM in front of it for Claude Code compatibility.

---

## LiteLLM standalone proxy

LiteLLM can proxy to nearly any model backend (OpenAI, Anthropic, Azure, Bedrock, Vertex, local models) while presenting an Anthropic-format API surface.

```bash
pip install litellm[proxy]

# Quick start — proxies to a local Ollama model
litellm --model ollama/mistral --port 4000
```

```
ANTHROPIC_BASE_URL=http://localhost:4000
```

See the [LiteLLM docs](https://github.com/BerriAI/litellm) for the full list of supported backends and configuration options.

---

## Remote self-hosted gateway

If you're running a model on a remote server (a GPU box, a cloud VM, etc.) and exposing it via HTTPS:

```
ANTHROPIC_BASE_URL=https://your-gateway.example.com
```

Make sure:
- TLS is properly configured (valid certificate or you accept the risk of self-signed)
- The gateway implements `/v1/messages` in Anthropic format
- `ANTHROPIC_API_KEY` matches whatever auth token your gateway expects

---

## Choosing a model

Claude Code performs best with instruction-following models that support tool use (function calling). Good starting points for open-weight models:

| Model family | Notes |
|---|---|
| Llama 3.x (8B, 70B) | Strong instruction following; 70B recommended for coding |
| Mistral / Mixtral | Good balance of speed and capability |
| Qwen 2.5 Coder | Fine-tuned for code; worth trying |
| Phi-3 / Phi-4 | Small but capable; good for low-resource setups |
| DeepSeek Coder | Coding-focused fine-tune |

Smaller models (7B and below) often struggle with complex agentic tasks. If Claude Code seems to loop, ignore instructions, or produce malformed tool calls, try a larger or more capable model.
