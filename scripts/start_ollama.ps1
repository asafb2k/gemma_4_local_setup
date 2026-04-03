param(
    [string]$Model = "gemma4:26b"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Checking Docker availability..."
docker info | Out-Null

Write-Host "Starting Ollama container..."
docker compose up -d ollama

Write-Host "Waiting for Ollama API on http://localhost:11434 ..."
$deadline = (Get-Date).AddMinutes(2)
$ready = $false

while ((Get-Date) -lt $deadline) {
    try {
        Invoke-RestMethod -Method Get -Uri "http://localhost:11434/api/version" -TimeoutSec 3 | Out-Null
        $ready = $true
        break
    } catch {
        Start-Sleep -Seconds 2
    }
}

if (-not $ready) {
    throw "Timed out waiting for Ollama to start."
}

Write-Host "Ollama is running. Pulling model $Model (this may take a while on first run)..."
docker exec gemma_4_local_setup-ollama-1 ollama pull $Model

Write-Host "Verifying model is available..."
$models = Invoke-RestMethod -Method Get -Uri "http://localhost:11434/api/tags"
$names = $models.models | ForEach-Object { $_.name }
Write-Host "Available models: $($names -join ', ')"

Write-Host "Ollama ready with $Model."
