param(
    [string]$Model = "gemma4:26b"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$env:ANTHROPIC_BASE_URL = "http://localhost:11434"
$env:ANTHROPIC_AUTH_TOKEN = "ollama"
$env:ANTHROPIC_API_KEY = ""

Write-Host "Launching Claude Code via claude-launcher (all role models remapped)..."
Write-Host "ANTHROPIC_BASE_URL=$env:ANTHROPIC_BASE_URL"
Write-Host "Model: $Model"
Write-Host ""
Write-Host "claude-launcher remaps Haiku/Sonnet/Opus roles to $Model"
Write-Host "so all requests stay local."

claude-launcher --model $Model
