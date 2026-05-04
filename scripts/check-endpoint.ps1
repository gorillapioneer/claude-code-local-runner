# check-endpoint.ps1
# Verify that the configured ANTHROPIC_BASE_URL endpoint is reachable
# and responds to /v1/models.
#
# Usage:
#   .\scripts\check-endpoint.ps1

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
$envFile    = Join-Path $projectDir ".env"

if (Test-Path $envFile) {
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
}

$baseUrl = $env:ANTHROPIC_BASE_URL
if (-not $baseUrl) {
    $baseUrl = "http://localhost:8000"
    Write-Host "[warn] ANTHROPIC_BASE_URL not set -- checking default: $baseUrl" -ForegroundColor Yellow
}

$modelsUrl = "$($baseUrl.TrimEnd('/'))/v1/models"

Write-Host ""
Write-Host "[check-endpoint]" -ForegroundColor Cyan
Write-Host "  Base URL   : $baseUrl"
Write-Host "  Probing    : $modelsUrl"
Write-Host ""

try {
    $headers = @{
        "x-api-key"           = if ($env:ANTHROPIC_API_KEY) { $env:ANTHROPIC_API_KEY } else { "dummy" }
        "anthropic-version"   = "2023-06-01"
    }

    $response = Invoke-WebRequest `
        -Uri $modelsUrl `
        -Headers $headers `
        -Method GET `
        -TimeoutSec 5 `
        -ErrorAction Stop

    Write-Host "[OK] Endpoint responded with HTTP $($response.StatusCode)" -ForegroundColor Green
    Write-Host ""

    try {
        $body   = $response.Content | ConvertFrom-Json
        $models = if ($body.data) { $body.data } elseif ($body.models) { $body.models } else { $null }
        if ($models) {
            Write-Host "Available models:" -ForegroundColor Cyan
            foreach ($m in $models) {
                $id = if ($m.id) { $m.id } else { $m }
                Write-Host "  - $id"
            }
        } else {
            Write-Host "Response (raw):" -ForegroundColor Cyan
            Write-Host $response.Content
        }
    } catch {
        Write-Host "Response (raw):" -ForegroundColor Cyan
        Write-Host $response.Content
    }

} catch [System.Net.WebException] {
    $status = $null
    if ($_.Exception.Response) {
        $status = [int]$_.Exception.Response.StatusCode
    }

    if ($status -eq 401) {
        Write-Host "[warn] HTTP 401 Unauthorized -- endpoint reachable but rejected the API key." -ForegroundColor Yellow
        Write-Host "       Set ANTHROPIC_API_KEY in your .env to whatever your server expects." -ForegroundColor Yellow
    } elseif ($status -eq 404) {
        Write-Host "[error] HTTP 404 Not Found at $modelsUrl" -ForegroundColor Red
        Write-Host "        Your server may not implement /v1/models." -ForegroundColor Red
        Write-Host "        If it only speaks the OpenAI format, add a LiteLLM proxy:" -ForegroundColor Red
        Write-Host "        https://github.com/BerriAI/litellm" -ForegroundColor Red
    } elseif (-not $status) {
        Write-Host "[error] Could not connect to $baseUrl" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Common causes:" -ForegroundColor Yellow
        Write-Host "    - Model server is not running"
        Write-Host "    - Wrong port in ANTHROPIC_BASE_URL"
        Write-Host "    - Firewall blocking the connection"
    } else {
        Write-Host "[error] HTTP $status -- $($_.Exception.Message)" -ForegroundColor Red
    }
} catch {
    Write-Host "[error] Unexpected error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
