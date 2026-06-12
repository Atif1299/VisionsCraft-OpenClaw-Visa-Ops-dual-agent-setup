# Update an existing Google Calendar event

param(

    [string]$EventId,

    [string]$Email,

    [string]$Phone,

    [string]$Name,

    [Alias("Notes")]

    [string]$Description,

    [string]$Summary,

    [string]$From,

    [string]$To,

    [string]$Account,

    [string]$CalendarId,

    [switch]$NotifyAttendees

)



$ErrorActionPreference = "Stop"

. "$PSScriptRoot\_calendar-config.ps1"

$config = Get-OpenClawCalendarConfig



if (-not $Account) { $Account = $config.organizerEmail }

if (-not $CalendarId) { $CalendarId = $config.calendarId }

$minYear = if ($config.minBookingYear) { [int]$config.minBookingYear } else { 2025 }



if (-not $EventId) {

    $booking = Find-ActiveBooking -Email $Email -Phone $Phone -Name $Name

    if (-not $booking) { throw "No active booking found. Provide -EventId or -Email/-Phone/-Name." }

    $EventId = $booking.eventId

    Write-Host "Using EVENT_ID=$EventId from bookings.jsonl"

}



$gog = "$env:USERPROFILE\.openclaw\bin\gog.exe"

if (-not (Test-Path $gog)) { throw "gog not found" }



if ($From -match '^(\d{4})-' -and [int]$Matches[1] -lt $minYear) {

    throw "Invalid year in From ($From). Use year $minYear or later with $($config.utcOffset)."

}



$gogArgs = @("calendar", "update", $CalendarId, $EventId, "--account", $Account)

if ($Description) { $gogArgs += @("--description", $Description) }

if ($Summary) { $gogArgs += @("--summary", $Summary) }

if ($From) { $gogArgs += @("--from", $From) }

if ($To) { $gogArgs += @("--to", $To) }

if ($NotifyAttendees) { $gogArgs += @("--send-updates", "all") }



& $gog @gogArgs

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }



if ($From -or $To) {

    $path = Get-OpenClawBookingsPath

    if (Test-Path $path) {

        $lines = Get-Content -Path $path

        $updated = @()

        foreach ($line in $lines) {

            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            $obj = $line | ConvertFrom-Json

            if ($obj.eventId -eq $EventId) {

                if ($From) { $obj.from = $From }

                if ($To) { $obj.to = $To }

            }

            $updated += ($obj | ConvertTo-Json -Compress)

        }

        Set-Content -Path $path -Value $updated -Encoding utf8

    }

}



Write-Host "Updated event $EventId"

