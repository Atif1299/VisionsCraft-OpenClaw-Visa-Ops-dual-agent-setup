# Sync versioned workspaces to ~/.openclaw (Visa + Ops + shared knowledge)
$ErrorActionPreference = "Stop"
$project = Split-Path $PSScriptRoot -Parent
$openclaw = "$env:USERPROFILE\.openclaw"
$visaLeadsLive = Join-Path $openclaw "workspace\leads\leads.jsonl"
$opsProspectsLive = Join-Path $openclaw "workspace-ops\prospects\prospects.jsonl"
$leadBackup = $null
$prospectBackup = $null
if (Test-Path $visaLeadsLive) {
    $leadBackup = Get-Content $visaLeadsLive -Raw -ErrorAction SilentlyContinue
}
if (Test-Path $opsProspectsLive) {
    $prospectBackup = Get-Content $opsProspectsLive -Raw -ErrorAction SilentlyContinue
}

Write-Host "Syncing Visa workspace..." -ForegroundColor Cyan
Copy-Item "$project\workspace\*" "$openclaw\workspace\" -Recurse -Force

Write-Host "Syncing Ops workspace..." -ForegroundColor Cyan
if (-not (Test-Path "$openclaw\workspace-ops")) {
    New-Item -ItemType Directory -Path "$openclaw\workspace-ops" -Force | Out-Null
}
Copy-Item "$project\workspace-ops\*" "$openclaw\workspace-ops\" -Recurse -Force

if ($leadBackup -and $leadBackup.Trim().Length -gt 0) {
    $dir = Split-Path $visaLeadsLive -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $visaLeadsLive -Value $leadBackup.TrimEnd() -Encoding utf8 -NoNewline
    Add-Content -Path $visaLeadsLive -Value "" -Encoding utf8
}
if ($prospectBackup -and $prospectBackup.Trim().Length -gt 0) {
    $dir = Split-Path $opsProspectsLive -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $opsProspectsLive -Value $prospectBackup.TrimEnd() -Encoding utf8 -NoNewline
    Add-Content -Path $opsProspectsLive -Value "" -Encoding utf8
}

$knowledgeSrc = "$project\knowledge"
if (Test-Path $knowledgeSrc) {
    foreach ($ws in @("workspace", "workspace-ops")) {
        $dest = Join-Path (Join-Path $openclaw $ws) "knowledge"
        if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
        Copy-Item $knowledgeSrc $dest -Recurse -Force
    }
}

$liveScripts = Join-Path $openclaw "workspace\scripts"
if (Test-Path $liveScripts) { Remove-Item $liveScripts -Recurse -Force }
New-Item -ItemType Directory -Path $liveScripts -Force | Out-Null
$calendarScripts = @(
    "_calendar-config.ps1",
    "lookup-booking.ps1",
    "book-consultation.ps1",
    "calendar-update-event.ps1",
    "calendar-delete-event.ps1",
    "calendar-check-slot.ps1"
)
foreach ($f in $calendarScripts) {
    $src = Join-Path $project "scripts\$f"
    if (Test-Path $src) { Copy-Item $src (Join-Path $liveScripts $f) -Force }
}

$calConfigPath = Join-Path $openclaw "workspace\calendar-config.json"
if (Test-Path $calConfigPath) {
    $cal = Get-Content $calConfigPath -Raw | ConvertFrom-Json
    $cal.scriptsDir = $liveScripts
    $cal.minBookingYear = (Get-Date).Year
    $cal | ConvertTo-Json | Set-Content $calConfigPath -Encoding utf8
}

foreach ($rel in @("workspace\leads", "workspace-ops\prospects", "workspace-ops\leads")) {
    $dir = Join-Path $openclaw $rel
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $jsonl = Join-Path $dir "$(Split-Path $rel -Leaf).jsonl"
    if (-not (Test-Path $jsonl)) { Set-Content -Path $jsonl -Value "" -Encoding utf8 }
}

$opsLeads = Join-Path $openclaw "workspace-ops\leads\leads.jsonl"
if (Test-Path $visaLeadsLive) {
    $content = Get-Content $visaLeadsLive -Raw -ErrorAction SilentlyContinue
    if ($content -and $content.Trim().Length -gt 0) {
        Set-Content -Path $opsLeads -Value $content.TrimEnd() -Encoding utf8 -NoNewline
        Add-Content -Path $opsLeads -Value "" -Encoding utf8
        Write-Host "Synced leads.jsonl Visa -> Ops" -ForegroundColor DarkGray
    }
}

Write-Host "Done. Live paths:" -ForegroundColor Green
Write-Host "  Visa: $openclaw\workspace"
Write-Host "  Ops:  $openclaw\workspace-ops"
Write-Host "  Scripts: $liveScripts"
