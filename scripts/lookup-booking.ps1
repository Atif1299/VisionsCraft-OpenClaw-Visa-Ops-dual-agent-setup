# Resolve Google Calendar event ID for a lead (by email, phone, or name)
param(
    [string]$Email,
    [string]$Phone,
    [string]$Name
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\_calendar-config.ps1"

if (-not $Email -and -not $Phone -and -not $Name) {
    throw "Provide at least one of: -Email, -Phone, -Name"
}

$booking = Find-ActiveBooking -Email $Email -Phone $Phone -Name $Name
if (-not $booking) {
    Write-Host "NOT_FOUND: No active booking for this lead."
    exit 1
}

Write-Host "EVENT_ID=$($booking.eventId)"
Write-Host "EMAIL=$($booking.email)"
Write-Host "FROM=$($booking.from)"
Write-Host "TO=$($booking.to)"
Write-Host "NAME=$($booking.name)"
