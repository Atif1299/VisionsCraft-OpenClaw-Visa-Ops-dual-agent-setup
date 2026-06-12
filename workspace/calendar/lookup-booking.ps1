$ErrorActionPreference = "Stop"
$config = Get-Content (Join-Path $PSScriptRoot "..\calendar-config.json") -Raw | ConvertFrom-Json
& (Join-Path $config.scriptsDir "lookup-booking.ps1") @args
exit $LASTEXITCODE
