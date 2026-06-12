function Get-OpenClawWorkspaceRoot {
    if ($env:OPENCLAW_WORKSPACE) { return $env:OPENCLAW_WORKSPACE }
    return Join-Path $env:USERPROFILE ".openclaw\workspace"
}

function Get-OpenClawCalendarConfig {
    $workspace = Get-OpenClawWorkspaceRoot
    $configPath = Join-Path $workspace "calendar-config.json"
    if (-not (Test-Path $configPath)) {
        throw "Missing calendar-config.json at $configPath"
    }
    $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
    if ($env:GOG_ACCOUNT) { $config | Add-Member -NotePropertyName organizerEmail -NotePropertyValue $env:GOG_ACCOUNT -Force }
    return $config
}

function Get-OpenClawBookingsPath {
    Join-Path (Get-OpenClawWorkspaceRoot) "bookings.jsonl"
}

function Get-OpenClawBookings {
    $path = Get-OpenClawBookingsPath
    if (-not (Test-Path $path)) { return @() }
    $rows = @()
    foreach ($line in Get-Content -Path $path) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $rows += ($line | ConvertFrom-Json) } catch { }
    }
    return $rows
}

function Find-ActiveBooking {
    param(
        [string]$Email,
        [string]$Phone,
        [string]$Name
    )
    $emailNorm = if ($Email) { $Email.Trim().ToLower() } else { $null }
    $phoneNorm = if ($Phone) { ($Phone -replace '\s', '') } else { $null }
    $nameNorm = if ($Name) { $Name.Trim().ToLower() } else { $null }

    $active = Get-OpenClawBookings | Where-Object { $_.status -eq 'active' }
    $matches = @($active | Where-Object {
        ($emailNorm -and $_.email -and ($_.email.ToLower() -eq $emailNorm)) -or
        ($phoneNorm -and $_.phone -and (($_.phone -replace '\s', '') -eq $phoneNorm)) -or
        ($nameNorm -and $_.name -and ($_.name.ToLower() -eq $nameNorm))
    })

    if ($matches.Count -eq 0) { return $null }
    return $matches | Sort-Object { [datetime]$_.createdAt } -Descending | Select-Object -First 1
}

function Add-OpenClawBooking {
    param(
        [string]$EventId,
        [string]$Name,
        [string]$Email,
        [string]$From,
        [string]$To,
        [string]$Notes,
        [string]$Phone
    )
    $path = Get-OpenClawBookingsPath
    $dir = Split-Path $path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    $row = [ordered]@{
        eventId   = $EventId
        name      = $Name
        email     = $Email.Trim().ToLower()
        phone     = $Phone
        from      = $From
        to        = $To
        notes     = $Notes
        status    = 'active'
        createdAt = (Get-Date).ToUniversalTime().ToString('o')
    }
    ($row | ConvertTo-Json -Compress) | Add-Content -Path $path -Encoding utf8
}

function Set-BookingStatus {
    param(
        [string]$EventId,
        [string]$Status
    )
    $path = Get-OpenClawBookingsPath
    if (-not (Test-Path $path)) { return }
    $lines = Get-Content -Path $path
    $updated = @()
    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $obj = $line | ConvertFrom-Json
        if ($obj.eventId -eq $EventId) { $obj.status = $Status }
        $updated += ($obj | ConvertTo-Json -Compress)
    }
    Set-Content -Path $path -Value $updated -Encoding utf8
}
