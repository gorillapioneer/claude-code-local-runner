# Example: Docker Model Runner

This example shows how to route Claude Code to [Docker Model Runner](https://docs.docker.com/ai/model-runner/) via `ANTHROPIC_BASE_URL`.

**What you get:** Claude Code as the terminal coding agent, sending requests to a model served locally by Docker Desktop.

**What this is not:** This does not run Anthropic's Claude models. Docker Model Runner runs open-weight models from Docker Hub. Model quality depends on what you pull and run.

---

## What is Docker Model Runner?

Docker Model Runner is a feature built into Docker Desktop (version 4.40 and later) that lets you pull and run open-weight AI models locally, similar to how you run containers. Models are pulled from Docker Hub and served over a local HTTP endpoint.

```bash
docker model pull ai/llama3.2
docker model run ai/llama3.2
```

The local endpoint is typically:

```
http://localhost:12434/engines/llama.cpp/v1
```

---

## API compatibility caveat

Docker Model Runner exposes an **OpenAI-compatible** API, not an Anthropic-format one. Claude Code sends requests in the **Anthropic Messages API** format (`/v1/messages`), which Docker Model Runner does not natively understand.

You have two options:

| Option | When to use |
|---|---|
| **LiteLLM proxy** (recommended) | Always works; adds a thin translation layer |
| **Direct connection** | Only if Docker Model Runner adds native Anthropic-format support in a future version |

Check the [Docker Model Runner release notes](https://docs.docker.com/ai/model-runner/) to see if native Anthropic format support has been added. As of this writing, a proxy is required.

---

## Setup with LiteLLM proxy (recommended)

```
Claude Code
    |  (Anthropic Messages API)
    v
LiteLLM proxy  :4000
    |  (OpenAI format)
    v
Docker Model Runner  :12434
    |
    v
Your model (llama3.2, etc.)
```

### Step 1 — Install Docker Desktop 4.40 or later

Download from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop). Docker Model Runner is included automatically.

### Step 2 — Pull and run a model

```bash
# Pull a model from Docker Hub
docker model pull ai/llama3.2

# Start the model runner
docker model run ai/llama3.2
```

Check available models:

```bash
docker model list
```

Confirm the local endpoint is responding:

```bash
curl http://localhost:12434/engines/llama.cpp/v1/models
```

You should see a JSON list of available models.

### Step 3 — Install LiteLLM

```bash
pip install 'litellm[proxy]'
```

### Step 4 — Create a LiteLLM config

Create `litellm_config.yaml`:

```yaml
model_list:
  - model_name: llama3.2
    litellm_params:
      model: openai/ai/llama3.2
      api_base: http://localhost:12434/engines/llama.cpp/v1
      api_key: dummy

litellm_settings:
  drop_params: true
```

Adjust `model_name` and the `model` value to match the model you pulled. The `model` value should be `openai/` followed by the model name as Docker Model Runner reports it at `/v1/models`.

### Step 5 — Start LiteLLM

```bash
litellm --config litellm_config.yaml --port 4000
```

Keep this terminal open while you use Claude Code.

### Step 6 — Configure `.env`

```
ANTHROPIC_BASE_URL=http://localhost:4000
ANTHROPIC_API_KEY=dummy
ANTHROPIC_MODEL=llama3.2
```

### Step 7 — Verify and start Claude Code

```bash
bash scripts/check-endpoint.sh     # or .\scripts\check-endpoint.ps1
./scripts/run-claude-local.sh      # or .\scripts\run-claude-local.ps1
```

---

## Direct connection (if Anthropic format is supported)

If a future Docker Desktop release adds native Anthropic Messages API support, you can skip LiteLLM entirely:

```
ANTHROPIC_BASE_URL=http://localhost:12434/engines/llama.cpp/v1
```

Run the check script to confirm — if you get a 200 on `/v1/models` and Claude Code connects without errors, no proxy is needed. If you get a `404` on `/v1/messages`, use the LiteLLM setup above.

---

## Notes on model quality

Docker Model Runner is designed for ease of use with models that fit in consumer-grade hardware. This means you are typically working with smaller models (3B–8B parameters), which have meaningful limitations on complex agentic tasks:

- Smaller models often struggle to follow multi-step tool-use instructions reliably.
- Claude Code may loop, produce incorrect edits, or misformat tool calls with weaker models.
- Coding-focused models generally perform better than general-purpose ones of the same size.

For a conservative starting point, copy [examples/CLAUDE.md](../CLAUDE.md) into your project root. It restricts the agent to read-only tasks (explain, suggest, document) until you've verified your model works reliably.

---

## Troubleshooting

**`docker model` command not found**
Docker Desktop 4.40 or later is required. Update Docker Desktop and try again.

**`connect ECONNREFUSED` on port 12434**
The model runner isn't active. Run `docker model run <model-name>` and wait for it to finish loading.

**`connect ECONNREFUSED` on port 4000**
LiteLLM isn't running. Start it in a separate terminal with `litellm --config litellm_config.yaml --port 4000` and keep it open.

**`404` on `/v1/messages`**
Docker Model Runner is serving OpenAI format only. Use the LiteLLM proxy setup above.

**`model not found` from LiteLLM**
The `model` field in your LiteLLM config doesn't match what Docker Model Runner reports at `/v1/models`. Check the exact model ID with `curl http://localhost:12434/engines/llama.cpp/v1/models` and update the config accordingly.

**Model is very slow**
Docker Model Runner uses CPU inference if no compatible GPU is detected. Performance on CPU is significantly slower than GPU. Check Docker Desktop's resource settings and confirm GPU acceleration is enabled if your hardware supports it.
