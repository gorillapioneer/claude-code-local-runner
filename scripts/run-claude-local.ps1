# run-claude-local.ps1
# Load .env (if present) and start Claude Code against a local endpoint.
#
# Usage:
#   . .\scripts\run-claude-local.ps1          # dot-source to keep env vars in your shell
#   .\scripts\run-claude-local.ps1            # run in subprocess (vars won't persist after)

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
$envFile    = Join-Path $projectDir ".env"

# Load .env file if it exists
if (Test-Path $envFile) {
    Write-Host "[info] Loading $envFile" -ForegroundColor Cyan
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith('#')) {
            $parts = $line -split '=', 2
            if ($parts.Count -eq 2) {
                $key   = $parts[0].Trim()
                $value = $parts[1].Trim()
                if (-not [System.Environment]::GetEnvironmentVariable($key)) {
                    [System.Environment]::SetEnvironmentVariable($key, $value, 'Process')
                }
            }
        }
    }
} else {
    Write-Host "[warn] No .env file found at $envFile" -ForegroundColor Yellow
    Write-Host "       Copy .env.example to .env and fill in your endpoint URL." -ForegroundColor Yellow
}

# Fall back to defaults if still not set
if (-not $env:ANTHROPIC_BASE_URL) {
    $env:ANTHROPIC_BASE_URL = "http://localhost:8000"
    Write-Host "[warn] ANTHROPIC_BASE_URL not set -- defaulting to http://localhost:8000" -ForegroundColor Yellow
}

if (-not $env:ANTHROPIC_API_KEY) {
    $env:ANTHROPIC_API_KEY = "dummy"
    Write-Host "[warn] ANTHROPIC_API_KEY not set -- defaulting to 'dummy'" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[claude-code-local-runner]" -ForegroundColor Green
Write-Host "  Endpoint : $env:ANTHROPIC_BASE_URL" -ForegroundColor Green
if ($env:ANTHROPIC_MODEL) {
    Write-Host "  Model    : $env:ANTHROPIC_MODEL" -ForegroundColor Green
}
Write-Host ""
Write-Host "Starting Claude Code. Type 'exit' inside Claude Code to quit." -ForegroundColor Cyan
Write-Host ""

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "[error] 'claude' command not found." -ForegroundColor Red
    Write-Host "        Install Claude Code: https://claude.ai/code" -ForegroundColor Red
    exit 1
}

claude
