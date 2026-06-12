# Backup OpenClaw state (Visa + Ops workspaces, leads, prospects)
$ErrorActionPreference = "Stop"
$src = "$env:USERPROFILE\.openclaw"
$dest = Join-Path (Split-Path $PSScriptRoot -Parent) "openclaw-backup"
$stamp = Get-Date -Format "yyyy-MM-dd_HHmm"

Write-Host "Backing up OpenClaw from $src" -ForegroundColor Cyan

$target = Join-Path $dest $stamp
New-Item -ItemType Directory -Path $target -Force | Out-Null

Copy-Item "$src\openclaw.json" $target -ErrorAction Stop
if (Test-Path "$src\.env") { Copy-Item "$src\.env" $target }
foreach ($dir in @("workspace", "workspace-ops", "credentials", "agents")) {
    if (Test-Path "$src\$dir") { Copy-Item "$src\$dir" "$target\$dir" -Recurse }
}

# Also snapshot versioned project knowledge
$project = Split-Path $PSScriptRoot -Parent
if (Test-Path "$project\knowledge") {
    Copy-Item "$project\knowledge" "$target\project-knowledge" -Recurse
}

Write-Host "Backup complete: $target" -ForegroundColor Green
Write-Host "Run weekly via Task Scheduler or: powershell -File scripts\backup-openclaw.ps1" -ForegroundColor Yellow
