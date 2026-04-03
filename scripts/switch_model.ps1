param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("google/gemma-4-31B-it", "google/gemma-4-26B-A4B-it", "google/gemma-4-E4B-it")]
    [string]$Model
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Switching TensorRT-LLM model to $Model"

$envPath = Join-Path $PSScriptRoot "..\.env"
"MODEL_ID=$Model" | Set-Content -Path $envPath -Encoding ASCII
Write-Host "Wrote $envPath"

docker compose --env-file $envPath up -d trtllm

Write-Host "Restart complete. Validating model endpoint..."
Start-Sleep -Seconds 5
Invoke-RestMethod -Uri "http://localhost:8000/v1/models" -Method Get | Out-Null
Write-Host "Model switch request applied."
