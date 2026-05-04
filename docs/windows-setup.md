# Windows setup guide

This guide walks through getting Claude Code running against a local or self-hosted Anthropic-compatible endpoint on Windows, using PowerShell.

---

## Prerequisites

- Windows 10 or Windows 11 (PowerShell 5.1+ is included; PowerShell 7 also works)
- A running local model endpoint — see [model-endpoints.md](model-endpoints.md) for setup options
- An internet connection for the initial Claude Code install

---

## Step 1 — Install Claude Code

Claude Code is Anthropic's AI coding agent CLI. Install it via npm:

```powershell
npm install -g @anthropic-ai/claude-code
```

If you don't have Node.js installed, download it from [nodejs.org](https://nodejs.org) first (LTS version recommended), then run the command above.

Verify the install:

```powershell
claude --version
```

You should see a version number. If you see `command not found`, see the troubleshooting section below.

---

## Step 2 — Clone this repo

```powershell
git clone https://github.com/YOUR_USERNAME/claude-code-local-runner.git
Set-Location claude-code-local-runner
```

Replace `YOUR_USERNAME` with the actual GitHub user or org where this repo lives.

---

## Step 3 — Copy `.env.example` to `.env`

```powershell
Copy-Item .env.example .env
```

The `.env` file is gitignored — it will never be committed.

---

## Step 4 — Configure `ANTHROPIC_BASE_URL`

Open `.env` in any editor:

```powershell
notepad .env
```

Set `ANTHROPIC_BASE_URL` to the address of your local model server. Examples:

```
# vLLM
ANTHROPIC_BASE_URL=http://localhost:8000

# LiteLLM proxy (e.g. in front of Ollama)
ANTHROPIC_BASE_URL=http://localhost:4000

# Docker Model Runner
ANTHROPIC_BASE_URL=http://localhost:12434/engines/llama.cpp/v1
```

Save and close. If your server requires a specific API key or token, set `ANTHROPIC_API_KEY` to that value. For most local servers, the default `dummy` works fine.

---

## Step 5 — Check your endpoint

Before starting Claude Code, confirm your model server is reachable:

```powershell
.\scripts\check-endpoint.ps1
```

A working endpoint prints something like:

```
[OK] Endpoint responded with HTTP 200

Available models:
  - llama3
```

If it fails, fix the issue before continuing. See the troubleshooting section below.

---

## Step 6 — Start Claude Code

```powershell
.\scripts\run-claude-local.ps1
```

The script loads your `.env`, prints the active endpoint, and launches `claude`. You should see Claude Code's interactive prompt.

To keep the environment variables in your current shell session after the script exits, dot-source it instead:

```powershell
. .\scripts\run-claude-local.ps1
```

---

## Troubleshooting

### `claude: command not found` or `claude` is not recognized

**Cause:** Claude Code isn't installed, or Node's global bin directory isn't on your `PATH`.

**Fix:**
1. Confirm Node.js is installed: `node --version`
2. Re-run: `npm install -g @anthropic-ai/claude-code`
3. Check the global bin path: `npm config get prefix` — the `bin` subfolder of that path must be in `$env:PATH`.
4. Restart your PowerShell window after changing `PATH`.

---

### PowerShell execution policy error

**Symptom:** Running the script produces an error like:
```
.\scripts\run-claude-local.ps1 cannot be loaded because running scripts is disabled on this system.
```

**Cause:** PowerShell's default execution policy blocks unsigned scripts.

**Fix (current session only — safest option):**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\run-claude-local.ps1
```

**Fix (current user, persistent):**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

`RemoteSigned` allows local scripts to run but still requires downloaded scripts to be signed. Don't use `Unrestricted` on a shared or production machine.

---

### `connect ECONNREFUSED` — endpoint refused

**Cause:** Your model server isn't running, or it's on a different port than `ANTHROPIC_BASE_URL` specifies.

**Fix:**
1. Start your model server (Ollama, vLLM, LiteLLM, Docker, etc.) first.
2. Confirm the port matches: run `check-endpoint.ps1` again after starting the server.
3. Check that no firewall rule is blocking the port.

---

### `HTTP 401 Unauthorized`

**Cause:** Your server is checking the API key and rejecting the value you've set.

**Fix:** Edit `.env` and set `ANTHROPIC_API_KEY` to the token your server expects. For most local servers this is any non-empty string like `dummy` or a token you configured when starting the server.

---

### `HTTP 404` on `/v1/messages` or `/v1/models`

**Cause:** Your server doesn't implement the Anthropic Messages API. It likely speaks OpenAI format only (e.g. a plain Ollama instance or a plain vLLM instance without Anthropic-format mode enabled).

**Fix:** Put [LiteLLM](https://github.com/BerriAI/litellm) in proxy mode in front of your server. LiteLLM translates Anthropic-format requests into whatever format your backend speaks. See [examples/ollama-litellm/](../examples/ollama-litellm/README.md) for a worked example.
