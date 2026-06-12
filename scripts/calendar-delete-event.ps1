# Delete a Google Calendar event

param(

    [string]$EventId,

    [string]$Email,

    [string]$Phone,

    [string]$Name,

    [string]$Account,

    [string]$CalendarId,

    [switch]$NotifyAttendees

)



$ErrorActionPreference = "Stop"

. "$PSScriptRoot\_calendar-config.ps1"

$config = Get-OpenClawCalendarConfig



if (-not $Account) { $Account = $config.organizerEmail }

if (-not $CalendarId) { $CalendarId = $config.calendarId }



if (-not $EventId) {

    $booking = Find-ActiveBooking -Email $Email -Phone $Phone -Name $Name

    if (-not $booking) { throw "No active booking found. Provide -EventId or -Email/-Phone/-Name." }

    $EventId = $booking.eventId

    Write-Host "Using EVENT_ID=$EventId from bookings.jsonl"

}



$gog = "$env:USERPROFILE\.openclaw\bin\gog.exe"

$gogArgs = @("calendar", "delete", $CalendarId, $EventId, "--account", $Account, "--force")

if ($NotifyAttendees) { $gogArgs += @("--send-updates", "all") }



& $gog @gogArgs

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }



Set-BookingStatus -EventId $EventId -Status "cancelled"

Write-Host "Deleted event $EventId"

