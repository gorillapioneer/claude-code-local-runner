#!/usr/bin/env bash
# check-endpoint.sh
# Verify that ANTHROPIC_BASE_URL is reachable and responds to /v1/models.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"

if [[ -f "$ENV_FILE" ]]; then
  echo "[info] Loading $ENV_FILE"
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

BASE_URL="${ANTHROPIC_BASE_URL:-http://localhost:8000}"
API_KEY="${ANTHROPIC_API_KEY:-dummy}"
MODELS_URL="${BASE_URL%/}/v1/models"

echo ""
echo "[check-endpoint]"
echo "  Base URL : $BASE_URL"
echo "  Probing  : $MODELS_URL"
echo ""

if ! command -v curl >/dev/null 2>&1; then
  echo "[error] curl is not installed."
  exit 1
fi

HTTP_CODE="$(
  curl -sS \
    -o /tmp/claude-code-local-runner-models.json \
    -w "%{http_code}" \
    -H "x-api-key: $API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    "$MODELS_URL" || true
)"

case "$HTTP_CODE" in
  200)
    echo "[OK] Endpoint responded with HTTP 200"
    echo ""
    cat /tmp/claude-code-local-runner-models.json
    echo ""
    ;;
  401)
    echo "[warn] HTTP 401 Unauthorized."
    echo "       Endpoint is reachable but rejected the API key."
    ;;
  404)
    echo "[error] HTTP 404 Not Found at $MODELS_URL"
    echo "        Your endpoint may not implement /v1/models."
    echo "        If it only speaks OpenAI format, use a LiteLLM proxy."
    ;;
  000|"")
    echo "[error] Could not connect to $BASE_URL"
    echo "        Check your model server, port, and firewall."
    ;;
  *)
    echo "[error] HTTP $HTTP_CODE"
    cat /tmp/claude-code-local-runner-models.json || true
    echo ""
    ;;
esac