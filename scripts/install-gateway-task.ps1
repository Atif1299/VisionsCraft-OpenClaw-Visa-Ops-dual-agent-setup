# Register Windows Task Scheduler job to start OpenClaw gateway at user logon
# Run once: powershell -ExecutionPolicy Bypass -File scripts\install-gateway-task.ps1
$ErrorActionPreference = "Stop"
$project = Split-Path $PSScriptRoot -Parent
$bat = Join-Path $project "start-gateway.bat"
$taskName = "VisionsCraft OpenClaw Gateway"

if (-not (Test-Path $bat)) { throw "Missing $bat" }

$action = New-ScheduledTaskAction -Execute $bat -WorkingDirectory $project
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
Write-Host "Registered scheduled task: $taskName" -ForegroundColor Green
Write-Host "It runs start-gateway.bat at logon. Keep only ONE gateway instance (do not also run manually)." -ForegroundColor Yellow
