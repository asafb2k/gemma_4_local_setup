param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("gemma4:31b", "gemma4:26b", "gemma4:e4b", "gemma4:e2b")]
    [string]$Model
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Unload all currently loaded models from GPU memory before switching.
# Ollama keeps models hot in VRAM after use; sending keep_alive=0 evicts them immediately.
Write-Host "Unloading any models currently loaded in GPU memory..."
try {
    $loaded = (Invoke-RestMethod -Uri "http://localhost:11434/api/ps").models
    foreach ($m in $loaded) {
        Write-Host "  Unloading $($m.name)..."
        Invoke-RestMethod -Uri "http://localhost:11434/api/generate" `
            -Method Post `
            -ContentType "application/json" `
            -Body (@{ model = $m.name; keep_alive = 0 } | ConvertTo-Json) | Out-Null
    }
} catch {
    Write-Host "  (Could not query running models — Ollama may not be running yet.)"
}

Write-Host "Pulling $Model (skipped if already downloaded)..."
docker exec gemma_4_local_setup-ollama-1 ollama pull $Model

Write-Host ""
Write-Host "Model $Model is ready."
Write-Host "Use it in CLI:        python .\cli\chat.py --model $Model"
Write-Host "Use it in Claude Code: .\scripts\start_claude_launcher.ps1 -Model $Model"
Write-Host "Or select it in Open-WebUI at http://localhost:3000"
