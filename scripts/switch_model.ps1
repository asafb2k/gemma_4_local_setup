param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("gemma4:31b", "gemma4:26b", "gemma4:e4b", "gemma4:e2b")]
    [string]$Model
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Pulling $Model in Ollama..."
docker exec gemma_4_local_setup-ollama-1 ollama pull $Model

Write-Host "Model $Model is now available."
Write-Host "Use it in CLI:  python .\cli\chat.py --model $Model"
Write-Host "Or in Open-WebUI select $Model from the model dropdown."
