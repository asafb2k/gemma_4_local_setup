Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$env:ANTHROPIC_BASE_URL = "http://localhost:4000"
$env:ANTHROPIC_AUTH_TOKEN = "sk-local-key"

Write-Host "Launching Claude Code with local LiteLLM bridge..."
Write-Host "ANTHROPIC_BASE_URL=$env:ANTHROPIC_BASE_URL"

claude
