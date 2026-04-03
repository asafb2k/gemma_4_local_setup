param(
    [string]$Model = "google/gemma-4-26B-A4B-it"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptsDir = $PSScriptRoot

Write-Host "Step 1/3: starting TensorRT-LLM..."
& (Join-Path $scriptsDir "start_trtllm.ps1") -Model $Model

Write-Host "Step 2/3: starting Open-WebUI..."
& (Join-Path $scriptsDir "start_webui.ps1")

Write-Host "Step 3/3: stack ready. Start LiteLLM in a separate shell:"
Write-Host "  .\scripts\start_litellm.ps1"
Write-Host ""
Write-Host "Then start Claude Code with:"
Write-Host "  .\scripts\start_claude_code.ps1"
