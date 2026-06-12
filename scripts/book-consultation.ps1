# Book a VisionsCraft consultation on Google Calendar

param(

    [Parameter(Mandatory)][string]$Name,

    [Parameter(Mandatory)][string]$Email,

    [Parameter(Mandatory)][string]$From,

    [Parameter(Mandatory)][string]$To,

    [string]$Phone,

    [string]$Notes = "Booked via WhatsApp lead agent",

    [string]$Account,

    [string]$CalendarId,

    [switch]$SkipConflictCheck

)



$ErrorActionPreference = "Stop"

. "$PSScriptRoot\_calendar-config.ps1"

$config = Get-OpenClawCalendarConfig



if (-not $Account) { $Account = $config.organizerEmail }

if (-not $CalendarId) { $CalendarId = $config.calendarId }

$minYear = if ($config.minBookingYear) { [int]$config.minBookingYear } else { 2025 }



$gog = "$env:USERPROFILE\.openclaw\bin\gog.exe"

if (-not (Test-Path $gog)) { throw "gog not found. See CALENDAR-SETUP.md" }



if ($From -match '^(\d{4})-' -and [int]$Matches[1] -lt $minYear) {

    throw "Invalid year in From ($From). Use year $minYear or later with $($config.utcOffset)."

}



$existing = Find-ActiveBooking -Email $Email -Phone $Phone

if ($existing) {

    Write-Host "ALREADY_BOOKED: Active event $($existing.eventId) for this email/phone. Use calendar-update-event.ps1 to reschedule."

    Write-Host "EVENT_ID=$($existing.eventId)"

    exit 3

}



if (-not $SkipConflictCheck) {

    $conflictOut = & $gog calendar conflicts --account $Account --from $From --to $To --cal $CalendarId 2>&1 | Out-String

    if ($conflictOut -match 'summary\t') {

        Write-Host "CONFLICT: Time slot is busy:" -ForegroundColor Yellow

        Write-Host $conflictOut

        Write-Host "Ask the lead for another time or run calendar-check-slot.ps1 with a different slot."

        exit 2

    }

}



$summary = "VisionsCraft consultation - $Name"

$attendees = "$Account,$Email"



$out = & $gog calendar create $CalendarId `

    --account $Account `

    --summary $summary `

    --from $From `

    --to $To `

    --attendees $attendees `

    --send-updates all `

    --description $Notes 2>&1 | Out-String



Write-Host $out

if ($out -match '(?m)^id\t(\S+)') {

    $eventId = $Matches[1]

    Write-Host "EVENT_ID=$eventId"

    Add-OpenClawBooking -EventId $eventId -Name $Name -Email $Email -Phone $Phone -From $From -To $To -Notes $Notes

}



Write-Host "Created event. Invites sent to $Email and $Account"

