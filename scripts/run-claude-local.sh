#!/usr/bin/env bash
# run-claude-local.sh
# Load .env (if present) and start Claude Code against a local endpoint.
#
# Usage:
#   chmod +x scripts/run-claude-local.sh
#   ./scripts/run-claude-local.sh
#   source ./scripts/run-claude-local.sh   # to keep env vars in your current shell

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"

if [[ -f "$ENV_FILE" ]]; then
    echo "[info] Loading $ENV_FILE"
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            if [[ -z "${!key+x}" ]]; then
                export "$key=$value"
            fi
        fi
    done < "$ENV_FILE"
else
    echo "[warn] No .env file found at $ENV_FILE"
    echo "       Copy .env.example to .env and fill in your endpoint URL."
fi

if [[ -z "${ANTHROPIC_BASE_URL:-}" ]]; then
    export ANTHROPIC_BASE_URL="http://localhost:8000"
    echo "[warn] ANTHROPIC_BASE_URL not set -- defaulting to http://localhost:8000"
fi

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    export ANTHROPIC_API_KEY="dummy"
    echo "[warn] ANTHROPIC_API_KEY not set -- defaulting to 'dummy'"
fi

echo ""
echo "[claude-code-local-runner]"
echo "  Endpoint : $ANTHROPIC_BASE_URL"
if [[ -n "${ANTHROPIC_MODEL:-}" ]]; then
    echo "  Model    : $ANTHROPIC_MODEL"
fi
echo ""
echo "Starting Claude Code. Type 'exit' inside Claude Code to quit."
echo ""

if ! command -v claude &>/dev/null; then
    echo "[error] 'claude' command not found."
    echo "        Install Claude Code: https://claude.ai/code"
    exit 1
fi

exec claude
