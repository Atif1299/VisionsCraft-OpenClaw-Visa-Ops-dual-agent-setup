$ErrorActionPreference = "Stop"
$config = Get-Content (Join-Path $PSScriptRoot "..\calendar-config.json") -Raw | ConvertFrom-Json
& (Join-Path $config.scriptsDir "calendar-delete-event.ps1") @args
exit $LASTEXITCODE
