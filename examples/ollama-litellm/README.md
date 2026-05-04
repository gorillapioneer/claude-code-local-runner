# Ollama + LiteLLM Example

This example shows how to use Claude Code with a local Ollama model through a LiteLLM proxy.

**Important:** This uses Claude Code as the agent with a local model endpoint — not Anthropic Claude running locally.

## Prerequisites

- [Ollama](https://ollama.com/) installed and running
- [LiteLLM](https://docs.litellm.ai/) installed (`pip install litellm`)
- [Claude Code](https://claude.ai/code) installed (`npm install -g @anthropic-ai/claude-code`)

## Quick Start

### 1. Start Ollama with your preferred model

```bash
ollama pull codellama
ollama serve
```

### 2. Start LiteLLM proxy

Use the included `litellm_config.yaml`:

```bash
litellm --config litellm_config.yaml
```

LiteLLM will start on `http://localhost:4000` by default.

### 3. Configure Claude Code

Create a `.env` file:

```bash
ANTHROPIC_BASE_URL=http://localhost:4000
ANTHROPIC_API_KEY=dummy
```

### 4. Run Claude Code

```bash
claude
```

Claude Code will now use your local Ollama model (via LiteLLM) instead of Anthropic's cloud API.

## Notes

- Local open-weight model quality differs from Anthropic's hosted Claude models. Expect different results on complex coding tasks.
- Most local servers accept any non-empty string as the API key.
- Adjust the model name in `litellm_config.yaml` to match your Ollama model.
