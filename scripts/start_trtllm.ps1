param(
    [string]$Model = $env:MODEL_ID
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $Model) {
    $Model = "google/gemma-4-26B-A4B-it"
}

Write-Host "Checking Docker availability..."
docker info | Out-Null

Write-Host "Verifying NVIDIA GPU passthrough..."
docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu22.04 nvidia-smi | Out-Null

$env:MODEL_ID = $Model
Write-Host "Starting trtllm with MODEL_ID=$Model"
docker compose up -d trtllm

Write-Host "Waiting for TensorRT-LLM API on http://localhost:8000/v1/models ..."
$deadline = (Get-Date).AddMinutes(20)
$ready = $false

while ((Get-Date) -lt $deadline) {
    try {
        $response = Invoke-RestMethod -Method Get -Uri "http://localhost:8000/v1/models" -TimeoutSec 5
        if ($response.data -and $response.data.Count -gt 0) {
            $ready = $true
            $modelIds = $response.data | ForEach-Object { $_.id }
            Write-Host "TensorRT-LLM is ready. Models: $($modelIds -join ', ')"
            break
        }
    } catch {
        Start-Sleep -Seconds 5
    }
}

if (-not $ready) {
    throw "Timed out waiting for trtllm to become ready."
}
