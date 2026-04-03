Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Starting Open-WebUI (and dependencies) with Docker Compose..."
docker compose up -d open-webui

Write-Host "Open-WebUI should be available at http://localhost:3000"
