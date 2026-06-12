# Check calendar conflicts for a time slot

param(

    [Parameter(Mandatory)][string]$From,

    [Parameter(Mandatory)][string]$To,

    [string]$Account,

    [string]$CalendarId

)



$ErrorActionPreference = "Stop"

. "$PSScriptRoot\_calendar-config.ps1"

$config = Get-OpenClawCalendarConfig



if (-not $Account) { $Account = $config.organizerEmail }

if (-not $CalendarId) { $CalendarId = $config.calendarId }



$gog = "$env:USERPROFILE\.openclaw\bin\gog.exe"

if (-not (Test-Path $gog)) { throw "gog not found" }



Write-Host "Checking conflicts $From to $To ..."

& $gog calendar conflicts --account $Account --from $From --to $To --cal $CalendarId 2>&1

$code = $LASTEXITCODE

if ($code -ne 0) { exit $code }

Write-Host "If no rows above, slot is free."

