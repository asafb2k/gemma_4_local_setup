param(
    [ValidateSet("gemma4:26b", "gemma4:31b", "gemma4:e4b", "gemma4:e2b")]
    [string]$Model
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$modelDescriptions = @{
    "gemma4:26b" = "26B MoE (3.8B active) — best speed/quality tradeoff (default)"
    "gemma4:31b" = "31B dense — highest quality, needs ~20GB VRAM"
    "gemma4:e4b" = "4B effective — fast iteration"
    "gemma4:e2b" = "2B effective — lightest, fastest"
}

if (-not $Model) {
    Write-Host ""
    Write-Host "Select Gemma 4 model variant:"
    Write-Host ""
    $choices = @("gemma4:26b", "gemma4:31b", "gemma4:e4b", "gemma4:e2b")
    for ($i = 0; $i -lt $choices.Count; $i++) {
        Write-Host "  [$($i+1)] $($choices[$i])  —  $($modelDescriptions[$choices[$i]])"
    }
    Write-Host ""
    $selection = Read-Host "Enter number (default: 1)"
    if (-not $selection) { $selection = "1" }
    $idx = [int]$selection - 1
    if ($idx -lt 0 -or $idx -ge $choices.Count) {
        Write-Error "Invalid selection."
        exit 1
    }
    $Model = $choices[$idx]
}

$env:ANTHROPIC_BASE_URL = "http://localhost:11434"
$env:ANTHROPIC_AUTH_TOKEN = "ollama"
$env:ANTHROPIC_API_KEY = ""

Write-Host ""
Write-Host "Launching Claude Code via claude-launcher (all role models remapped)..."
Write-Host "ANTHROPIC_BASE_URL=$env:ANTHROPIC_BASE_URL"
Write-Host "Model: $Model  —  $($modelDescriptions[$Model])"
Write-Host "All Haiku/Sonnet/Opus role requests will route to $Model locally."
Write-Host ""

claude-launcher --model $Model
