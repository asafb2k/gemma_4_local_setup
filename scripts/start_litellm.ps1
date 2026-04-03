Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$configPath = Join-Path $PSScriptRoot "..\configs\litellm_config.yaml"

Write-Host "Starting LiteLLM proxy on port 4000..."
Write-Host "Config: $configPath"
Write-Host "Run this from an activated gemma_4_env conda shell."

litellm --config $configPath --host 0.0.0.0 --port 4000
